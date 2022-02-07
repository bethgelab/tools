#!/bin/bash

mkdir "$SCRATCH"/small_files
for id in $(seq -f'%.0f' 1000); do
    echo "hello world" > "$SCRATCH"/small_files/small_file_"$id"
done

# 1.458s slurm-bm-80 -> slurm-bm-81 # bethge partition
# 0.529s slurm-bm-63 -> slurm-bm-24 # gpu-2080 partition
# 0.4-0.7s slurm-bm-25 -> slurm-bm-27 # gpu-2080 partition
time scp "$SCRATCH"/small_files/* \
        gpachitariu37@192.168.212.56:/scratch_local/gpachitariu37-1158003

mkdir "$SCRATCH"/large_files
for id in $(seq -f'%.0f' 10); do
    head -c 1G < /dev/urandom > "$SCRATCH"/large_files/1gb_file_"$id"
done

# 55.34s - 186MB/s slurm-bm-80 -> slurm-bm-81 
# 58.38s - 176.1MB/s  slurm-bm-63 -> slurm-bm-24 
# 55.31s - 186.9MB/s  slurm-bm-25 -> slurm-bm-27
time scp "$SCRATCH"/large_files/* scp gpachitariu37@192.168.212.56:/scratch_local/gpachitariu37-1158003
