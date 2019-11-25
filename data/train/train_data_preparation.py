def create_text_file():
    f = open('wav.scp', 'r')
    n = open('text', 'w')
    context = f.readlines()
    for line in context:
        file_name = line.split()[0]
        ans = ""
        for char in file_name:
            if char == 'A' or char == 'B':
                continue
            ans += word_dict()[char] + ' '
        ans = ans[:-1]
        n.write(file_name + ' ' + ans + '\n')


def word_dict():
    words_dict = {'1': "ONE", '2': "TWO", '3': "THREE", '4': "FOUR", '5': "FIVE", '6': "SIX", '7': "SEVEN",
                  '8': "EIGHT",
                  '9': "NINE", 'Z': "ZERO", 'O': "OH"}
    return words_dict


if __name__ == "__main__":
    create_text_file()
