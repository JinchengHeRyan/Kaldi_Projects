#!/bin/bash
. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc

# data_path=/mingback/linqj/ivector_gender/v1/timit/TIMIT
data_path=waves_data

# The trials file is downloaded by local/make_voxceleb1.pl.
voxceleb1_trials=data/voxceleb1_test/trials
# voxceleb1_root=/export/corpora/VoxCeleb1
# voxceleb2_root=/export/corpora/VoxCeleb2



stage=1

# TODO: fix
if [ $stage -le 0 ]; then
  local/make_voxceleb2.pl $voxceleb2_root dev data/voxceleb2_train
  local/make_voxceleb2.pl $voxceleb2_root test data/voxceleb2_test
  # This script reates data/voxceleb1_test and data/voxceleb1_train.
  # Our evaluation set is the test portion of VoxCeleb1.
  local/make_voxceleb1.pl $voxceleb1_root data
  # We'll train on all of VoxCeleb2, plus the training portion of VoxCeleb1.
  # This should give 7,351 speakers and 1,277,503 utterances.
  utils/combine_data.sh data/train data/voxceleb2_train data/voxceleb2_test data/voxceleb1_train
fi

if [ $stage -le 1 ]; then

  # Prepare data
  local/prepare_data.sh $data_path

  # Prepare trials
  rm -f $voxceleb1_trials
  touch $voxceleb1_trials
  python3 local/produce_trials.py data/voxceleb1_test/utt2spk $voxceleb1_trials

  echo "Stage $stage Begin! "
  # Make MFCCs and compute the energy-based VAD for each dataset
  for name in train voxceleb1_test; do
    steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj 8 --cmd "$train_cmd" data/${name} exp/make_mfcc $mfccdir
    utils/fix_data_dir.sh data/${name}
    sid/compute_vad_decision.sh --nj 8 --cmd "$train_cmd" data/${name} exp/make_vad $vaddir
    utils/fix_data_dir.sh data/${name}
  done
  echo "Stage $stage Finish! "
  stage=2
fi

if [ $stage -le 2 ]; then
  echo "Stage $stage Begin! "
  # Train the UBM.
  sid/train_diag_ubm.sh --cmd "$train_cmd --mem 4G" --nj 40 --num-threads 8 data/train 1024 exp/diag_ubm
  sid/train_full_ubm.sh --cmd "$train_cmd --mem 25G" --nj 40 --remove-low-count-gaussians false data/train exp/diag_ubm exp/full_ubm
  echo "Stage $stage Finish! "
  stage=3
fi

if [ $stage -le 3 ]; then
  echo "Stage $stage Begin! "
  # In this stage, we train the i-vector extractor.
  #
  # Note that there are well over 1 million utterances in our training set,
  # and it takes an extremely long time to train the extractor on all of this.
  # Also, most of those utterances are very short.  Short utterances are
  # harmful for training the i-vector extractor.  Therefore, to reduce the
  # training time and improve performance, we will only train on the 100k
  # longest utterances.

  # utils/subset_data_dir.sh --utt-list <(sort -n -k 2 data/train/utt2num_frames | tail -n 100000) data/train data/train_100k

  # Train the i-vector extractor.
  # sid/train_ivector_extractor.sh --cmd "$train_cmd --mem 16G" --ivector-dim 400 --num-iters 5 exp/full_ubm/final.ubm data/train_100k exp/extractor
  sid/train_ivector_extractor.sh --cmd "$train_cmd --mem 16G" --ivector-dim 400 --num-iters 5 exp/full_ubm/final.ubm data/train exp/extractor
  echo "Stage $stage Finish! "
  stage=4
fi

if [ $stage -le 4 ]; then
  echo "Stage $stage Begin! "
  sid/extract_ivectors.sh --cmd "$train_cmd --mem 4G" --nj 80 exp/extractor data/train exp/ivectors_train
  sid/extract_ivectors.sh --cmd "$train_cmd --mem 4G" --nj 80 exp/extractor data/voxceleb1_test exp/ivectors_voxceleb1_test
  echo "Stage $stage Finish! "
  stage=5
fi

# exit 0

if [ $stage -le 5 ]; then
  echo "Stage $stage Begin! "
  # Compute the mean vector for centering the evaluation i-vectors.
  $train_cmd exp/ivectors_train/log/compute_mean.log \
    ivector-mean scp:exp/ivectors_train/ivector.scp \
    exp/ivectors_train/mean.vec || exit 1;

  # This script uses LDA to decrease the dimensionality prior to PLDA.
  lda_dim=200
  $train_cmd exp/ivectors_train/log/lda.log \
    ivector-compute-lda --total-covariance-factor=0.0 --dim=$lda_dim \
    "ark:ivector-subtract-global-mean scp:exp/ivectors_train/ivector.scp ark:- |" \
    ark:data/train/utt2spk exp/ivectors_train/transform.mat || exit 1;

  # Train the PLDA model.
  $train_cmd exp/ivectors_train/log/plda.log \
    ivector-compute-plda ark:data/train/spk2utt \
    "ark:ivector-subtract-global-mean scp:exp/ivectors_train/ivector.scp ark:- | transform-vec exp/ivectors_train/transform.mat ark:- ark:- | ivector-normalize-length ark:-  ark:- |" \
    exp/ivectors_train/plda || exit 1;
  echo "Stage $stage Finish! "
  stage=6
fi

if [ $stage -le 6 ]; then
  echo "Stage $stage Begin! "
  $train_cmd exp/scores/log/voxceleb1_test_scoring.log \
    ivector-plda-scoring --normalize-length=true \
    "ivector-copy-plda --smoothing=0.0 exp/ivectors_train/plda - |" \
    "ark:ivector-subtract-global-mean exp/ivectors_train/mean.vec scp:exp/ivectors_voxceleb1_test/ivector.scp ark:- | transform-vec exp/ivectors_train/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "ark:ivector-subtract-global-mean exp/ivectors_train/mean.vec scp:exp/ivectors_voxceleb1_test/ivector.scp ark:- | transform-vec exp/ivectors_train/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "cat '$voxceleb1_trials' | cut -d\  --fields=1,2 |" exp/scores_voxceleb1_test || exit 1;
  echo "Stage $stage Finish! "
  stage=7
fi

if [ $stage -le 7 ]; then
  echo "Stage $stage Begin! "
  eer=`compute-eer <(local/prepare_for_eer.py $voxceleb1_trials exp/scores_voxceleb1_test) 2> /dev/null`
  mindcf1=`sid/compute_min_dcf.py --p-target 0.01 exp/scores_voxceleb1_test $voxceleb1_trials 2> /dev/null`
  mindcf2=`sid/compute_min_dcf.py --p-target 0.001 exp/scores_voxceleb1_test $voxceleb1_trials 2> /dev/null`
  echo "EER: $eer%"
  echo "minDCF(p-target=0.01): $mindcf1"
  echo "minDCF(p-target=0.001): $mindcf2"
  # EER: 5.329%
  # minDCF(p-target=0.01): 0.4933
  # minDCF(p-target=0.001): 0.6168
  echo "Stage $stage Finish! "
  stage=8
fi
