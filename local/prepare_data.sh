mkdir data/
mkdir data/test/
mkdir data/train/

# Prepare utt2spk in train and test
for x in train test; do
    find waves_data/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/$x/utt2spk
done

# Prepare wav.scp in train and test
for x in train test; do
    find waves_data/$x/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/$x/wav.scp
done

# Prepare text in train and test
for x in train test; do
    rm -f data/$x/text
    touch data/$x/text
    cd data/$x
    python3 ../../local/data_preparation.py
    cd ../../
done

# Prepare words.txt in train and test
for x in train test; do
    cd data/$x/
    cut -d ' ' -f 2- text | sed 's/ /\n/g' | sort -u > words.txt
    cd ../../
done