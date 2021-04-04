import tensorflow as tf

import numpy as np
import IPython.display as display

# imagenetc_path = '/mnt/qb/bethge/gpachitariu37/datasets/imagenet_c/'
imagenetc_path = '/home/george/datasets/tfrecord/'

filenames = [filename]
raw_dataset = tf.data.TFRecordDataset(filenames)
raw_dataset

for raw_record in raw_dataset.take(10):
  print(repr(raw_record))

for image_features in parsed_image_dataset:
  image_raw = image_features['image_raw'].numpy()
  display.display(display.Image(data=image_raw))
