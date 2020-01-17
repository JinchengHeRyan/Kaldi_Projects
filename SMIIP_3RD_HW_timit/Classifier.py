import kaldi_io
import numpy as np
from sklearn import svm
test_file = "exp/ivectors_voxceleb1_test/ivector.scp"
test_data = []
test_target = []
train_data = []
train_target = []
for key,mat in kaldi_io.read_mat_scp(test_file):
    test_data.append(mat)
    test_target.append(key[0])

train_file = "exp/ivectors_train/ivector.scp"
for key,mat in kaldi_io.read_mat_scp(train_file):
    train_data.append(mat)
    train_target.append(key[0])

train_data = np.array(train_data)
nsamples, nx, ny = train_data.shape
train_data = train_data.reshape((nsamples,nx*ny))

test_data = np.array(test_data)
nsamples, nx, ny = test_data.shape
test_data = test_data.reshape((nsamples,nx*ny))

clf = svm.SVC()
clf.fit(X=train_data, y=train_target,sample_weight=None)

result = clf.predict(test_data)
print(result)
accurate_num = 0
for i in range(len(result)):
    if result[i] == test_target[i]:
        accurate_num += 1
print(accurate_num / len(result))