#!/bin/bash
cd /home/jincheng/SMIIP_1ST_HW
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
compute-mfcc-feats --verbose=2 --config=conf/mfcc.conf scp,p:exp/make_mfcc/data/train/wav_train.${SGE_TASK_ID}.scp ark:- | copy-feats --compress=true ark:- ark,scp:/home/jincheng/SMIIP_1ST_HW/mfcc/raw_mfcc_train.${SGE_TASK_ID}.ark,/home/jincheng/SMIIP_1ST_HW/mfcc/raw_mfcc_train.${SGE_TASK_ID}.scp 
EOF
) >exp/make_mfcc/data/train/make_mfcc_train.$SGE_TASK_ID.log
time1=`date +"%s"`
 ( compute-mfcc-feats --verbose=2 --config=conf/mfcc.conf scp,p:exp/make_mfcc/data/train/wav_train.${SGE_TASK_ID}.scp ark:- | copy-feats --compress=true ark:- ark,scp:/home/jincheng/SMIIP_1ST_HW/mfcc/raw_mfcc_train.${SGE_TASK_ID}.ark,/home/jincheng/SMIIP_1ST_HW/mfcc/raw_mfcc_train.${SGE_TASK_ID}.scp  ) 2>>exp/make_mfcc/data/train/make_mfcc_train.$SGE_TASK_ID.log >>exp/make_mfcc/data/train/make_mfcc_train.$SGE_TASK_ID.log
ret=$?
time2=`date +"%s"`
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>exp/make_mfcc/data/train/make_mfcc_train.$SGE_TASK_ID.log
echo '#' Finished at `date` with status $ret >>exp/make_mfcc/data/train/make_mfcc_train.$SGE_TASK_ID.log
[ $ret -eq 137 ] && exit 100;
touch exp/make_mfcc/data/train/q/sync/done.94833.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# qsub -v PATH -cwd -S /bin/bash -j y -l arch=*64* -o exp/make_mfcc/data/train/q/make_mfcc_train.log   -t 1:16 /home/jincheng/SMIIP_1ST_HW/exp/make_mfcc/data/train/q/make_mfcc_train.sh >>exp/make_mfcc/data/train/q/make_mfcc_train.log 2>&1
