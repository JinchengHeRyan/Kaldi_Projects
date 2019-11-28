local/prepare_data.sh waves_data
local/prepare_dict.sh
local/prepare_lm.sh

# Prepare spk2utt
utils/fix_data_dir.sh data/train

# utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang

. ./cmd.sh

# MFCC Feature extraction
for x in train test; do 
 steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 utils/fix_data_dir.sh data/$x
done

steps/make_mfcc.sh --cmd $train_cmd --nj 1 data/train exp/make_mfcc/data/train mfcc