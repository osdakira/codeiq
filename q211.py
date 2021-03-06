# coding: utf-8

# 1. 出現頻度を出力するPythonの処理プログラム。
from __future__ import absolute_import
from nltk.corpus import names
from nltk.probability import ConditionalFreqDist

# 名前も記録しておいて後で見たい。
end_word_name_map = {}  # ←本件とは直接関係ないので無視してください。

cfdist = ConditionalFreqDist()
for file_id in names.fileids():
    for name in names.words(file_id):
        cfdist[name[-1]].inc(file_id)
        end_word_name_map.setdefault(file_id, {}).setdefault(name[-1], []).append(name)

f = open("q211_answer.txt", "w")
print >> f, "WordEnding,female.txt,male.txt"
for end_word, dist in sorted(cfdist.items()):
    female_count = dist.get("female.txt", 0)
    male_count = dist.get("male.txt", 0)
    print >> f, "{},{},{}".format(end_word, female_count, male_count)

# 2. 男女の人名の語末文字の上位３位は何であるか。上位３位の語末文字から何が言えるか、気づいた点を書いてください。
def print_top3(file_id):
    for end_word, dist in sorted(cfdist.items(), key=lambda (end_word, dist): dist.get(file_id, 0), reverse=True)[:3]:
        print end_word, dist.get(file_id, 0)
        print end_word_name_map[file_id].get(end_word)[:5]

## 女性の語末上位3位は、a, e, y の順
print_top3("female.txt")
# a 1773
# e 1432
# y 461

## 男性の語末上位3位は、n, e, y の順
print_top3("male.txt")
# n 478
# e 468
# y 332

## 気づいた点
# 1. 男性女性共に多いのは、e と y で終わる名前。どちらの性でも使える名前が多いと考える。但し、e に関しては 女性: 1432 に対し、 男性: 468 であり、女性名としての e が多い。
# 2. 女性の1位、2位が 1000 を超えている事に対し、男性 1位は 500に届いておらず、男性名はより分散していると考える。(日本で女性名に「子」が付くことが多いことと同じ現象であると考える)
