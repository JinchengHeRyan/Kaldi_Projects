mkdir data/
mkdir data/test/
mkdir data/train/
# Prepare utt2spk in train

find waves_data/train/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/train/utt2spk
# Prepare wav.scp in train
find waves_data/train/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/train/wav.scp

# Prepare text in train
rm -f data/train/text
touch data/train/text
cd data/train
python3 ../../local/train_data_preparation.py
cd ../../

# Prepare words.txt in train
cd data/train/
cut -d ' ' -f 2- text | sed 's/ /\n/g' | sort -u > words.txt
cd ../../

# Prepare utt2spk in test
find waves_data/test/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/test/utt2spk
# Prepare wav.scp in test
find waves_data/test/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/test/wav.scp

# Prepare text in test
rm -f data/test/text
touch data/test/text
cd data/test
python3 ../../local/test_data_preparation.py
cd ../../

# Prepare words.txt in test
cd data/test/
cut -d ' ' -f 2- text | sed 's/ /\n/g' | sort -u > words.txt
cd ../../