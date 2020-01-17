import kaldi_io
import numpy as np
from sklearn import svm
test_data = []
test_target = []
train_data = []
train_target = []
test_file = "exp/ivectors_voxceleb1_test/ivector.scp"
for key,mat in kaldi_io.read_mat_scp(test_file):
    test_data.append(mat)
    test_target.append(key)

train_file = "exp/ivectors_train/ivector.scp"
for key,mat in kaldi_io.read_mat_scp(train_file):
    train_data.append(mat)
    train_target.append(key)

for person in test_target:
    if person in train_target:
        print("Error, there is duplicate person")
print("Do not exist duplicate person")