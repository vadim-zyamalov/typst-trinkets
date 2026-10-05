import sys

fname = sys.argv[1]

with open("ju2pdft.typ", "r", encoding="utf8") as f:
    lines = f.readlines()

with open(f".ipynb/{fname}.typ", "w", encoding="utf8") as f:
    f.writelines(line.replace("<DUMMY>", fname) for line in lines)
