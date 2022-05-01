
""" 
cd /home/george/Desktop
rm -rf tuebingen_logs
mkdir tuebingen_logs
scp gpachitariu37@slurm2:/mnt/beegfs/bethge/gpachitariu37/logs/* tuebingen_logs
cd /home/george/git/tools/slurm

python benchmark_fs_process_logs.py
"""

import os
import numpy as np
import re

lines = []
# dir="/home/george/Desktop/tuebingen_logs" # "karolina_logs"
dir = "/home/george/Desktop/logs/gpach_tuebingen_test"
for folder in os.listdir(dir):
    with open(dir+"/"+folder+"/"+"logs", "r") as r:
        for line in r.read().splitlines():
            prefix = "/mnt/beegfs/bethge/gpachitariu37/gpach_tuebingen_test"
            if line.startswith(prefix):
                lines.append(line[len(prefix)+1:])
        
dict = {}
for l in lines:
    splits=l.split(" ")
    key=" ".join(splits[1:-1])
    value = splits[-1]

    if key not in dict:
        dict[key] = []
    
    dict[key].append(float(value))

s = ""
for k, v in dict.items():
    if "Deleting" in k:
        continue

    k = re.sub(' +', ' ', k)

    d = 0
    d = 0.14648 if "150K" in k else d
    d = 1 if "1M" in k else d
    d = 1024 if "1G" in k else d
    
    no_files=int(k.split(" ")[6])

    mean = np.round(np.mean(v), 2)
    min = np.round(np.min(v), 2)
    max = np.round(np.max(v), 2)
    
    s += f"{k}\tmean (min|max):{mean} ({min} | {max})\t"
    s += f"count:{len(v)}\t"
    s += f"GB/s:{np.round(len(v) * no_files * d / (mean * 1024), 2)}"

    s += "\n"

with open("log_results.txt", "w") as w:
    w.write(s)

# get the values:
#cat karolina_logs/* | grep "/home/it4i-gpach/gpach_tuebingen_test Test type: small_files Number of files: 1000                 Writing time (seconds)" | rev | cut -d" " -f 1 | rev