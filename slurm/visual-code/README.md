Visual Code on Slurm

There is an implementation of Visual Code that runs in the browser (like Jupyter) and it's called Code Server:
https://github.com/cdr/code-server

### Initial setup 
You need to download an older version of the python and jupyter plugin because the latest one is broken:
https://github.com/cdr/code-server/issues/2341#issuecomment-740892890

On the head-node in Slurm run:
```sh
rm -r ~/.local/share/code-server
mkdir -p ~/.local/share/code-server/
mkdir -p ~/.local/share/code-server/User
echo "{\"extensions.autoCheckUpdates\": false, \"extensions.autoUpdate\": false}" > ~/.local/share/code-server/User/settings.json

# download an older python plugin
mkdir vs_temp
cd vs_temp
wget https://github.com/microsoft/vscode-python/releases/download/2020.10.332292344/ms-python-release.vsix
# you need to install the plugin, but you can only install it using the code-server container
srun --partition=gpu-2080ti-interactive singularity \
         run docker://georgepachitariu/slurm-visual-code:1.1 \
         code-server --install-extension ./vs_temp/ms-python-release.vsix

```

### To run it:

Run on Slurm:
```sh
port=10412 # pick your favorite number > 10000
srun -w "bg-slurmb-bm-2" --time 12:0:0 --gres=gpu:1 \
    --partition="gpu-2080ti-interactive" singularity \
    run --nv -B /scratch_local -B /mnt/qb/datasets \
    docker://georgepachitariu/slurm-visual-code:1.1 \
    code-server --bind-addr 0.0.0.0 --port $port
```

Run locally:
```sh
# the node hostname and the port number need to match with above ones
username="gpachitariu37"
port=10412
ssh -N -f -L localhost:10100:bg-slurmb-bm-2:$port $username@slurm
```

Finally go in the browser to [localhost:10100](localhost:10100). If the setup was done correctly you should see Visual Code.
