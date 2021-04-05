# %%
# The easiest/fastest way (in my opinion) to learn about the storage format "TFRecord" and 
# the library "tfrecord", is to download a tfrecord file from the slurm cluster locally 
# (i.e. with linux scp) and run this script in Visual Studio Code or Pycharm. 
# (You don't need a GPU) 
# Then you can:
# 1. Run blocks of code and use breakpoints to inspect variables;
# 2. Access the documentation and the underlying code (to see for example how TFRecordDataset
#       was implemented and how the function arguments are used);

from PIL import Image
import numpy as np, io
from tfrecord.torch.dataset import TFRecordDataset
import torch, torchvision.transforms as trn
from torchvision.datasets import ImageFolder
import matplotlib.pyplot as plt

# I run the python script locally on my laptop, but both folders contain the same data. 
# imagenetc_path = '/mnt/qb/bethge/gpachitariu37/datasets/imagenet_c/'
imagenetc_path = '/home/george/datasets/tfrecord/'

# This is where the magic happens. TFRecordDataset object reads 
# records from TFRecords files and passes them to PyTorch.
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

# %%
# Print the value of corruption_type column from the first record (image)
raw_dataset = load_dataset()
raw_loader = torch.utils.data.DataLoader(raw_dataset, 
        batch_size=1, shuffle=False, num_workers=1)
first_record = next(iter(raw_loader))
print('1. First record corruption type: ', end=' ')
print(first_record['corruption_type'].\
        numpy().tobytes().decode("utf-8"))

# %%
#Use transforms
transformed_dataset = load_dataset( transform=trn.Compose([ 
        lambda record: Image.open(io.BytesIO(record["image_raw"].tobytes())),
        trn.ToTensor(),
        trn.CenterCrop(224), 
        ]))
transformed_loader = torch.utils.data.DataLoader(
        transformed_dataset, batch_size=1, 
        shuffle=False, num_workers=1
        )
transformed_record = next(iter(transformed_loader))
# Both Visual Studio Code and Jupyter can display images 
plt.imshow(transformed_record.squeeze().permute(1,2,0))
plt.show()