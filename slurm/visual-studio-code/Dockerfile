# Uploaded to: docker://georgepachitariu/slurm-visual-code
# Available on Slurm at: 
# /home/bethge/gpachitariu37/slurm-visual-code_latest.sif
FROM pytorch/pytorch

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get install -y git
    
# https://github.com/cdr/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN pip install jupyter
RUN pip install pylint
RUN pip install nbconvert
RUN pip install tensorboard

CMD "code-server"
