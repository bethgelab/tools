"""
To run this:
srun --pty --partition=gpu-2080ti-interactive singularity exec  \
    -B /mnt/qb/bethge/gpachitariu37/datasets/imagenet_c \
    docker://georgepachitariu/bethgelab-tools \
    python read_pytorch.py
"""

from PIL import Image
import numpy as np, io
import torch, torchvision, torchvision.transforms as trn
from tfrecord.torch.dataset import TFRecordDataset
from torchvision.datasets import ImageFolder

imagenetc_path = '/mnt/qb/bethge/gpachitariu37/datasets/imagenet_c/'
#imagenetc_path = '/home/george/datasets/tfrecord/'

# TFRecordDataset object reads records from TFRecords files and passes them to PyTorch.
def load_dataset(transform=None):
    filename="zoom_blur_1"
    return TFRecordDataset(
                    data_path=imagenetc_path+filename+'.tfrecords', 
                    index_path=imagenetc_path+filename+'.tfrecords_index',
                    description={ 'height': 'int',
                                'width':  'int',
                                'depth':  'int',
                                'corruption_type': 'byte',
                                'severity_level' : 'int',
                                'class_label': 'byte',
                                'image_raw':  'byte' }, 
                    transform=transform)

# Print the value of corruption_type column from the first record (image)
raw_dataset = load_dataset()
raw_loader = torch.utils.data.DataLoader(raw_dataset, batch_size=1, shuffle=False, num_workers=1)
first_record = next(iter(raw_loader))
print('1. First record corruption type: ', end=' ')
print(first_record['corruption_type'].numpy().tobytes().decode("utf-8"))

# Print prediction for first record and use transforms to decode, crop and normalize the images
transformed_dataset = load_dataset( transform=trn.Compose([ 
                                        lambda record: Image.open(io.BytesIO(record["image_raw"].tobytes())),
                                        trn.ToTensor(),
                                        trn.CenterCrop(224), 
                                        trn.Normalize(mean=[0.485, 0.456, 0.406], 
                                                      std=[0.229, 0.224, 0.225])
                                        ]))
transformed_loader = torch.utils.data.DataLoader(transformed_dataset, batch_size=1, shuffle=False, num_workers=1)
transformed_record = next(iter(transformed_loader))
resnet50 = torchvision.models.resnet50(pretrained = True)
output = resnet50(transformed_record)
print("2. Class predicted for the first record: " + str(output.argmax()))

# to see the image
#import matplotlib.pyplot as plt
#plt.imshow(transformed_record.squeeze().permute(1, 2, 0))
#plt.show()
