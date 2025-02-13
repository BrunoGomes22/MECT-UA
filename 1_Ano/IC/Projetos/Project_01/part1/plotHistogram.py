import matplotlib.pyplot as plt
import matplotlib
import csv

matplotlib.rcParams.update(
    {
        'text.usetex': False,
        'font.family': 'DejaVu Sans',   # Change font to DejaVu Sans
        'font.size': 12                 # Set font size
    }
)

charDict = {}
wordDict = {}
with open('charData.csv', 'r') as dataFile:
    reader = csv.reader(dataFile)
    for row in reader:
        char = chr(int(row[0])) # convert ASCII code to character
        count_str = ''.join(row[1:])
        count = int(count_str.replace(',', ''))
        charDict[char] = count
# 40 most frequent characters
sorted_items = sorted(charDict.items(), key=lambda item: item[1], reverse=True)[:40]

charDict = {k: v for k, v in sorted_items}
filtered_charDict = {k: v for k, v in charDict.items() if ord(k) >= 32 } # remove non-printable ASCII characters

plt.figure(1)
plt.bar(filtered_charDict.keys(), filtered_charDict.values())
plt.title('Character Frequency')

with open('wordData.csv', 'r') as dataFile:
    reader = csv.reader(dataFile)
    for row in reader:
        word = row[0]
        count = int(row[1])
        wordDict[word] = count


# sort the dictionary by count and only keep the top 20 words
wordDict = dict(sorted(wordDict.items(), key=lambda item: item[1], reverse=True)[:20])

plt.figure(2,figsize=(10, 8))
plt.barh(list(wordDict.keys()), list(wordDict.values()))
plt.title('Word Frequency')

plt.xscale('log')

plt.show()


#for char, count in charDict.items():
#    print(f"Character: {char}, Unicode: {ord(char)}, Count: {count}")
