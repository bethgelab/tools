#!/bin/bash

username="gpachitariu37"
node="bg-slurmb-bm-2"
port="10412" # change this
partition="gpu-2080ti-interactive"

# connect to Slurm, clean if there is a job running already on interactive partition
# and submit a new job.
ssh -f $username@slurm "
    scancel --user=$username --partition=$partition
    srun -w $node \
         --time 12:0:0 \
         -o logs.out -e logs.err \
         --gres=gpu:1 \
         --partition=$partition singularity \
         run --nv \
         docker://georgepachitariu/slurm-visual-code:1.0 \
         code-server --port $port &
    echo 'srun command submitted'
"

# clean any existing tunnels and create a new one
pgrep -f 'ssh.*localhost:10100' | xargs kill
ssh -N -f -L localhost:10100:$node:$port $username@slurm &
