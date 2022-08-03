Visual Studio Code on Slurm

There is an implementation of Visual Studio Code that runs in the browser (like Jupyter) and it's called Code Server:
https://github.com/cdr/code-server

Remotely (on SLurm) run:
```sh
port=10412 # pick your favorite number > 10000
srun -w "bg-slurmb-bm-2" --time 12:0:0 --gres=gpu:1 \
    --partition="gpu-2080ti-interactive" singularity \
    run --nv -B /scratch_local -B /mnt/qb/datasets \
    /home/bethge/gpachitariu37/slurm-visual-code_latest.sif \
    code-server --bind-addr 0.0.0.0 --port $port
```

Locally run:
```sh
# the node hostname and the port number need to match with above ones
username="gpachitariu37"
port=10412
ssh -N -f -L localhost:10100:bg-slurmb-bm-2:$port $username@slurm
```

Finally go in the browser to [localhost:10100](localhost:10100). If the setup was done correctly you should see Visual Studio Code.

You can install VS Plugins like Python, Jupyter from the vs-code in the browser. They get installed in `$HOME/.local/share/code-server' folder. If it ever happes that the plugins stop working correctly, just delete this folder, and install plugins again.
