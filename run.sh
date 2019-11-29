local/prepare_data.sh waves_data
local/prepare_dict.sh
local/prepare_lm.sh
utils/validate_lang.pl data/lang/

# utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang

. ./cmd.sh

# MFCC Feature extraction
for x in train test; do 
 steps/make_mfcc.sh --cmd $train_cmd --nj 16 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
done

# Monophone training and alignment

# Train
# # Subsetting data
# utils/subset_data_dir.sh --first data/train 1000 data/train_1k

# steps/train_mono.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
# data/train_1k data/lang exp/mono_1k

# # Align
# steps/align_si.sh --boost-silence 1.25 --nj 16 --cmd "$train_cmd" \
# data/train data/lang exp/mono_1k exp/mono_ali || exit 1;

steps/train_mono.sh  --nj 4 --cmd "$train_cmd" \
  data/train data/lang exp/mono0a

utils/mkgraph.sh data/lang exp/mono0a exp/mono0a/graph && \
steps/decode.sh --nj 10 --cmd "$decode_cmd" \
   exp/mono0a/graph data/test exp/mono0a/decode

steps/align_si.sh --boost-silence 1.25 --nj 16 --cmd "$train_cmd" \
data/train data/lang exp/mono0a exp/mono0a_ali



# steps/align_si.sh --nj 4 --cmd "$train_cmd" \
#    data/train data/lang exp/mono0a exp/mono0a_ali

# steps/train_deltas.sh --cmd "$train_cmd" \
#     300 3000 data/train data/lang exp/mono0a_ali exp/tri1


#  utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
#  steps/decode.sh --nj 10 --cmd "$decode_cmd" \
#       exp/tri1/graph data/test exp/tri1/decode