# Uploaded to: docker://georgepachitariu/slurm-visual-code
# Available on Slurm at: 
# /home/bethge/gpachitariu37/slurm-visual-code_latest.sif
FROM pytorch/pytorch
# The nvidia drivers are installed on the Slurm machines, so you don't need to install them again here.
# However if you want a specific version you can use:
# FROM nvcr.io/nvidia/pytorch:22.01-py3

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get install -y git && \
    apt-get install -y libglib2.0-0

RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=4.4.0
# The python and Jupyter extensions cannot be installed through Dockerfile,
# because the instalation directory needs to be writable (that's where the user sessions are stored).
# The extensions are installed through the UI and stored in the home folder.

RUN pip install jupyter
RUN pip install pylint
RUN pip install nbconvert
RUN pip install tensorboard

RUN pip install torchvision==0.8.2
RUN pip install numpy
RUN pip install pytest
RUN pip install scipy
