#!/usr/bin/python3

import os
import shutil

os.chdir(os.path.dirname(os.path.realpath(__file__)))
os.chdir("..")

basedir = os.getcwd()
assert basedir.endswith("/addons/swampcode")

for f in os.listdir():
    if not (f.startswith("src_") or f.startswith(".")):
        shutil.rmtree(f)

for srcroot in list(os.listdir()):
    if f.startswith("src_"):
        os.chdir(os.path.join(basedir, srcroot))
        for root, dirs, files in os.walk(".", topdown=False):
            if root == "." or ".git" in root:
                continue
            # print(root, files)
            root = root[2:].replace("\\", "/")
            for f in files:
                f = root + "/" + f
                if f.endswith(".lua"):
                    use = True
                    with open(f, "r") as ff:
                        ff.readline()
                        line2 = ff.readline()
                        if "INSTALL" in line2 and "CINEMA" in line2:
                            use = False
                    if use:
                        os.makedirs(os.path.dirname(
                            os.path.join("..", f)), exist_ok=True)
                        shutil.copyfile(f, os.path.join("..", f))
                        print(f)
