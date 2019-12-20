import sys

fnutt = sys.argv[1]
ftrial = open(sys.argv[2], 'w')

for line_1 in open(fnutt):
  utt_1 = line_1.rstrip('\r\t\n ').split(' ')[0]
  for line_2 in open(fnutt):
    utt_2 = line_2.rstrip('\r\t\n ').split(' ')[0]
    if utt_1.split('_')[0] == utt_2.split('_')[0]:
      trial = utt_1 + ' ' + utt_2 + ' target'
    else:
      trial = utt_1 + ' ' + utt_2 + ' nontarget'
    ftrial.write(trial + '\n')
ftrial.close()
