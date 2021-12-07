#!/usr/bin/python3

import os
import shutil

lua_dir = "/swamp/workspace"
output_dir = "/swamp/repos/contrib"


luadocs = [

]


os.chdir(lua_dir)
for root, dirs, files in os.walk(".", topdown=False):
    for f in files:
        if f.endswith(".lua"):
            f = root[2:] + "/" + f
            
            comment = None

            with open(f) as fp:
                for line in fp.readlines():
                    line = line.strip()

                    if comment is None:
                        if line.startswith("---") and len(line)>3 and line[3]!="-":
                            comment = line[3:].strip()
                    else:
                        if line.startswith("--") and len(line)>2 and line[2]!="-":
                            comment += "\n" + line[2:].strip()
                        elif line=="":
                            # todo: file comment?
                            comment = None
                        else:
                            luadocs.append({
                                "code":line,
                                "comment": comment,
                                "file": f
                            })

luadocs.sort(key= lambda x: x["file"]+" "+x["code"])

docgen = "".join(
    f"""# {x["code"]}
{x["comment"]}
*file: {x["file"]}*
""" for x in luadocs
)

with open(output_dir+"/readme_format.md") as fp:
    fmt = fp.read()

with open(output_dir+"/README.md", "w") as fp:
    fp.write(fmt.replace("DOCSGOHERE", docgen))
