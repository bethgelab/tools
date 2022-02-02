import os
import numpy as np

lines = []
dir="tuebingen_logs" # "karolina_logs"
for file in os.listdir(dir):
    with open(dir+"/"+file, "r") as r:
        lines.extend(r.read().splitlines())
        
dict = {}
for l in lines:
    if l.startswith("/"):
        splits=l.split(" ")
        key=" ".join(splits[:-1])
        value = splits[-1]

        if key not in dict:
            dict[key] = []
        
        dict[key].append(float(value))

s = ""
for k, v in dict.items():
    s += f"{k} mean:{np.round(np.mean(v), 2)} "
    s += f"min:{np.round(np.min(v), 2)} "
    s += f"max:{np.round(np.max(v), 2)} "
    s += f"count:{len(v)}"
    s += "\n"

with open("log_results.txt", "w") as w:
    w.write(s)

# get the values:
#cat karolina_logs/* | grep "/home/it4i-gpach/gpach_tuebingen_test Test type: small_files Number of files: 1000                 Writing time (seconds)" | rev | cut -d" " -f 1 | rev