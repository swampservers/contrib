

import os
import shutil

os.chdir(os.path.dirname(os.path.realpath(__file__)))
os.chdir("..")
print(os.getcwd())

assert os.getcwd().endswith("/addons/swampcode")

# for f in os.listdir():
#     print(f)

