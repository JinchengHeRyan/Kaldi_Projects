def create_text_file():
    f = open('wav.scp', 'r')
    n = open('text', 'w')
    context = f.readlines()
    for line in context:
        file_name_full = line.split()[0]
        file_name = line.split()[0].split('_')[1]
        ans = ""
        for char in file_name:
            if char == 'A' or char == 'B':
                continue
            ans += word_dict()[char] + ' '
        ans = ans[:-1]
        n.write(file_name_full + ' ' + ans + '\n')


def word_dict():
    words_dict = {'1': "1", '2': "2", '3': "3", '4': "4", '5': "5", '6': "6", '7': "7",
                  '8': "8",
                  '9': "9", 'Z': "z", 'O': "o"}
    return words_dict


if __name__ == "__main__":
    create_text_file()
