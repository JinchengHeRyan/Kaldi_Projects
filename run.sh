local/prepare_data.sh waves_data
local/prepare_dict.sh
local/prepare_lm.sh

# utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang

. ./cmd.sh

# MFCC Feature extraction
for x in train test; do 
 steps/make_mfcc.sh --cmd $train_cmd --nj 16 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
done
