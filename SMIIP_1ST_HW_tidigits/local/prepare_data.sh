mkdir -p data/test/
mkdir -p data/train/
WAVES_DATA_PATH=$1
# Prepare utt2spk in train and test
for x in train test; do
    find ${WAVES_DATA_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $4"_"$5, $4}' | sort > data/$x/utt2spk

# Prepare wav.scp in train and test
    find ${WAVES_DATA_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $4"_"$5, "/home/kaldi/tools/sph2pipe_v2.5/sph2pipe -f wav "$0" |"}' | sort > data/$x/wav.scp
    # find ${WAVES_DATA_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $4"_"$5, "/home/kaldi/tools/sph2pipe_v2.5/sph2pipe -f rif "$0" |"}' | sort > data/$x/wav.scp
    # find ${WAVES_DATA_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{printf("%s '/home/kaldi/tools/sph2pipe_v2.5/sph2pipe' -f wav %s |\n", $4"_"$5, $0);}' > data/$x/wav.scp

# Prepare text in train and test
    rm -f data/$x/text
    touch data/$x/text
    cd data/$x
    python3 ../../local/data_preparation.py
    cd ../../

# Prepare words.txt in train and test
    cd data/$x/
    cut -d ' ' -f 2- text | sed 's/ /\n/g' | sort -u > words.txt
    cd ../../
# Prepare spk2utt
    utils/fix_data_dir.sh data/$x
done
