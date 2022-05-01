
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

lines = []
dir="/home/george/Desktop/tuebingen_logs" # "karolina_logs"
for file in os.listdir(dir):
    with open(dir+"/"+file, "r") as r:
        for line in r.read().splitlines():
            prefix = "/mnt/beegfs/bethge/gpachitariu37/benchmark/slurm_script"
            if line.startswith(prefix):
                lines.append(line[len(prefix)+1:])
        
dict = {}
for l in lines:
    splits=l.split(" ")
    key=" ".join(splits[:-1])
    value = splits[-1]

    if key not in dict:
        dict[key] = []
    
    dict[key].append(float(value))

s = ""
for k, v in dict.items():
    k = ("small files" if "small_files" in k else "large_files") + k.split("  ")[-1]

    s += f"{k} mean:{np.round(np.mean(v), 2)} "
    s += f"min:{np.round(np.min(v), 2)} "
    s += f"max:{np.round(np.max(v), 2)} "
    s += f"count:{len(v)}"
    s += "\n"

with open("log_results.txt", "w") as w:
    w.write(s)

# get the values:
#cat karolina_logs/* | grep "/home/it4i-gpach/gpach_tuebingen_test Test type: small_files Number of files: 1000                 Writing time (seconds)" | rev | cut -d" " -f 1 | rev