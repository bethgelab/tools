# Uploaded to: docker://georgepachitariu/slurm-visual-code
# Available on Slurm at: 
# /home/bethge/gpachitariu37/slurm-visual-code_latest.sif
FROM pytorch/pytorch

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get install -y git && \
    apt-get install -y libglib2.0-0

# https://github.com/cdr/code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN pip install jupyter
RUN pip install pylint
RUN pip install nbconvert
RUN pip install tensorboard

# Beit requirements
RUN pip install torchvision==0.8.2
RUN pip install timm==0.3.2
RUN pip install Pillow
RUN pip install blobfile
RUN pip install mypy
RUN pip install numpy
RUN pip install pytest
RUN pip install requests
RUN pip install einops
RUN pip install tensorboardX
RUN pip install deepspeed==0.4.0
RUN pip install scipy
RUN pip install scikit-image
RUN pip install opencv-python

CMD "code-server"
