# We also need to create an index file for each data file.
# More details here: https://github.com/vahidk/tfrecord

"""
To run this script:
srun --pty --partition=gpu-2080ti-interactive singularity exec  \
    -B /mnt/qb/bethge/gpachitariu37/datasets/imagenet_c \
    docker://georgepachitariu/bethgelab-tools \
    python convert_dataset_2_indexes.py \
    /mnt/qb/bethge/gpachitariu37/datasets/imagenet_c
"""

import os, sys
from tfrecord.tools import tfrecord2idx

if __name__ == "__main__":
    imagenet_c_folder = str(sys.argv[1])
    
    for tfrecord_file in os.listdir(imagenet_c_folder):
        tfrecord_name, file_extension = tfrecord_file.split('.') 
        
        tfrecord2idx.create_index( 
            imagenet_c_folder+'/'+tfrecord_name+'.'+file_extension,
            imagenet_c_folder+'/'+tfrecord_name+'.'+'tfrecords_index')

