# Uploaded: docker://georgepachitariu/slurm-visual-code
FROM pytorch/pytorch

RUN apt-get update
RUN apt-get install -y curl

# https://github.com/cdr/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN pip install jupyter
RUN pip install pylint
RUN pip install nbconvert
RUN pip install tensorboard

CMD "code-server"
