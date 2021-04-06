# This image is on dockerhub at: 
# https://hub.docker.com/r/georgepachitariu/bethgelab-tools
FROM python:buster

RUN pip install --no-cache-dir --upgrade pip

# Install PyTorch: command generated automatically on https://pytorch.org/
RUN pip install --no-cache-dir torch==1.8.1+cu111 torchvision==0.9.1+cu111 \
    torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html

# This is needed to read TFRecord files in PyTorch
RUN pip install --no-cache-dir tfrecord==1.11 

CMD [ "bash" ]