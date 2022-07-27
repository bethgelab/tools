# %%
""" 
cd /home/george/Desktop
rm -rf tuebingen_logs
rsync -r --exclude="file*" --include="logs" gpachitariu37@slurm2:/mnt/beegfs/bethge/gpachitariu37/gpach_tuebingen_test tuebingen_logs
cd /home/george/git/tools/slurm

python benchmark_fs_process_logs.py
"""

import os
import numpy as np
import pandas as pd
import re

intervals=[]
dir = "/home/george/Desktop/tuebingen_logs/gpach_tuebingen_test"
for folder in os.listdir(dir):
    logs_file = dir+"/"+folder+"/"+"logs"
    if not os.path.exists(logs_file):
        continue
    with open(logs_file, "r") as r:
        for line in r.read().splitlines():
            prefix = "/mnt/beegfs/bethge/gpachitariu37/gpach_tuebingen_test"
            if not line.startswith(prefix):
                continue
            
            type=None
            if "Reading" in line:
                type = "Reading"
            elif "Writing" in line:
                type = "Writing"
            else:
                print(f"Unknown row found: {line}")
                continue

            d = None
            d = 0.14648 if "150K" in line else d
            d = 1 if "1M" in line else d
            d = 1024 if "1G" in line else d
            
            no_files=int(line.split(" ")[6])
            start_time=int(line.split(" ")[1])
            finish_time=int(line.split(" ")[2])
            
            speed=no_files * d / ((finish_time-start_time) * 1024) # GB/s

            start = ((start_time-1)//5+1)*5
            for time_interval in range(start, finish_time, 5):
                intervals.append([time_interval, speed, type])

# %%
df = pd.DataFrame(intervals, columns=["time", "speed", "type"])

sum_read = df[df["type"] == "Reading"][["time", "speed"]].groupby("time").sum()
max_read= sum_read["speed"].max()

sum_write = df[df["type"] == "Writing"][["time", "speed"]].groupby("time").sum()
max_write= sum_write["speed"].max()

print(f"Max Read:{max_read}; Max Write:{max_write}")
print(f"Avg Read:{sum_read['speed'].mean()}; Avg Write:{sum_write['speed'].mean()}")
