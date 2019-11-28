# Copy lexicon.txt into data/local/lang/
mkdir -p data/local/lang/
cp input/lexicon.txt data/local/lang/

# Create nonsilence_phones.txt silence_phones.txt optional_silence.txt
cd data/local/lang/
cut -d ' ' -f 2- lexicon.txt | sed 's/ /\n/g' | sort -u > nonsilence_phones.txt
echo -e 'SIL'\\n'oov' > silence_phones.txt
echo 'SIL' > optional_silence.txt
cd ../../../

utils/prepare_lang.sh data/local/lang 'OOV' data/local/ data/lang
