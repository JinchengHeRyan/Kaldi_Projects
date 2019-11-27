mkdir -p data/test/
mkdir -p data/train/
waves_data_PATH=waves_data
# Prepare utt2spk in train and test
for x in train test; do
    find ${waves_data_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/$x/utt2spk

# Prepare wav.scp in train and test
    find ${waves_data_PATH}/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/$x/wav.scp

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
done