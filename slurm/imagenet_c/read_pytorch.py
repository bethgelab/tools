"""
To run this:
srun --pty --partition=gpu-2080ti-interactive singularity exec  \
    -B /mnt -B /mnt/qb/bethge/gpachitariu37/datasets \
    docker://tensorflow/tensorflow \
    python /home/bethge/gpachitariu37/imagenetc_convert_dataset.py \
    /mnt/qb/datasets/ImageNet-C /mnt/qb/bethge/gpachitariu37/datasets/imagenet_c
"""

import torch
import torchvision
import torchvision.transforms as trn
from tfrecord.torch.dataset import TFRecordDataset

imagenetc_path = '/mnt/qb/bethge/gpachitariu37/datasets/imagenet_c/'
imagenetc_path = '/home/george/datasets/tfrecord'

# This function is where the magic happens. The function configures a dataset object 
# that reads TFRecords files and can be loaded into PyTorch.
def get_dataset(root_folder, transform=None):
    tfrecord_path = imagenetc_path
    index_path = root_folder + 'images.tfrecords_index'
    description = { 'height': 'int',
                    'width':  'int',
                    'depth':  'int',
                    'corruption_type': 'byte',
                    'severity_level' : 'int',
                    'class_label': 'byte',
                    'image_raw':  'byte' }

    return TFRecordDataset(tfrecord_path, index_path, description, transform=transform)

dataset = get_dataset( root_folder='',
                       transform=trn.Compose([
                                trn.CenterCrop(224), 
                                trn.ToTensor(), 
                                trn.Normalize(mean = [0.485, 0.456, 0.406], 
                                            std = [0.229, 0.224, 0.225])]
                     ))
loader = torch.utils.data.DataLoader(dataset, batch_size=1, shuffle=False, num_workers=1)

# 1. Print the value of corruption_type column from the first record (image)
first_record = next(iter(loader))
print('pink elephant')
print(first_record['corruption_type'].numpy().tobytes().decode("utf-8"))

resnet50 = torchvision.models.resnet50(pretrained = True)
output = resnet50(first_record['image_raw'])
print(output)
