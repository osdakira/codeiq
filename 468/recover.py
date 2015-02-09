# coding: utf-8

start = [c for c in "12345"]
sep = "."
end = "1.2.3.4.5"

line = start
print line

if line[-1] != sep:
    line[-1:-1] = [sep]
if line[4] < line[5]:
    pass

print line


# weeks = []
# for l in open("numdot.txt"):
#     weeks.append([c for c in l.strip()])

# print weeks

# 12345
# 1234.5


# 1.2.3.45
# 1.2.3.4.5
