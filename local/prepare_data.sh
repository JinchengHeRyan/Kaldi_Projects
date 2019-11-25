# Prepare utt2spk in train
find waves_data/train/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/train/utt2spk
# Prepare wav.scp in train
find waves_data/train/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/train/wav.scp

# Prepare text in train
rm -f data/train/text
touch data/train/text
cd data/train
python3 train_data_preparation.py
cd ../../

# Prepare utt2spk in test
find waves_data/test/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $4}' > data/test/utt2spk
# Prepare wav.scp in train
find waves_data/test/ -name "*.WAV" | sort | awk -F '[/.]' '{print $5, $0}' > data/test/wav.scp

# Prepare text in train
rm -f data/test/text
touch data/test/text
cd data/test
python3 test_data_preparation.py
cd ../../