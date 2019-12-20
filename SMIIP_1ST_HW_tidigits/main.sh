mkdir outputs
for ((gauss_num=10000; gauss_num<=30000; gauss_num+=1000)); do
    feature_type=mfcc
    ./run.sh $feature_type $gauss_num > outputs/output_${feature_type}_${gauss_num}; 
done
