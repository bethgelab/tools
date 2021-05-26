# Uploaded: docker://georgepachitariu/slurm-visual-code
FROM pytorch/pytorch

RUN apt-get update
RUN apt-get install -y curl

# https://github.com/cdr/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --port
CMD "code-server"

# .config/code-server/config.yaml

# srun --pty -w bg-slurmb-bm-2 --gres=gpu:1 --partition=gpu-2080ti-interactive singularity run --nv docker://georgepachitariu/slurm-visual-code:1.0 code-server --port 10412
# ssh -N -f -L localhost:10100:bg-slurmb-bm-2:10412 gpachitariu37@slurm

