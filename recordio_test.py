import torch
import torchvision
import torchvision.datasets as dset
import torchvision.transforms as trn
import numpy as np
from torch.autograd import Variable as V

# Getting the dataset
# $ wget https://zenodo.org/record/2235448/files/blur.tar?download=1 > imagenet_c/blur.tar


# It's pretrained on ImageNet
net = torchvision.models.resnet50(pretrained = True)

mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]

# copied from: https://github.com/hendrycks/robustness/blob/master/ImageNet-C/test.py
def show_performance(distortion_name):
    errs = []

    for severity in range(1, 2):
        distorted_dataset = dset.ImageFolder(
            root='~/datasets/imagenet_c/' + distortion_name + '/' + str(severity),
            transform=trn.Compose([trn.CenterCrop(224), trn.ToTensor(), trn.Normalize(mean, std)]))

        # TODO I changed batch_size to 64 from 128.
        distorted_dataset_loader = torch.utils.data.DataLoader(
            distorted_dataset, batch_size=64, shuffle=False, num_workers=1)

        correct = 0
        for batch_idx, (data, target) in enumerate(distorted_dataset_loader):
            data = V(data, volatile=True)

            output = net(data)

            pred = output.data.max(1)[1]
            correct += pred.eq(target).sum()

            print(batch_idx)

        errs.append(1 - 1.*correct / len(distorted_dataset))

    print('\n=Average', tuple(errs))
    return np.mean(errs)


distortions = ['defocus_blur' #, 'glass_blur', 'motion_blur', 'zoom_blur'
]

error_rates = []
for distortion_name in distortions:
    rate = show_performance(distortion_name)
    error_rates.append(rate)
    print('Distortion: {:15s}  | CE (unnormalized) (%): {:.2f}'.format(distortion_name, 100 * rate))
