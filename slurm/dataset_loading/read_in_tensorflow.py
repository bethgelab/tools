# %%
# The tfrecord files were written using tensorflow library. 
# So it will be straightforward to read the files back using the same library. 
# More tips: https://www.tensorflow.org/tutorials/load_data/tfrecord
import tensorflow as tf
import numpy as np
import IPython.display as display

# imagenetc_path = '/mnt/qb/bethge/gpachitariu37/datasets/imagenet_c/'
imagenetc_path = '/home/george/datasets/tfrecord/'

filenames = [imagenetc_path + "zoom_blur_1.tfrecords"]
raw_dataset = tf.data.TFRecordDataset(filenames)

image_feature_description = {
    'height': tf.io.FixedLenFeature([], tf.int64),
    'width': tf.io.FixedLenFeature([], tf.int64),
    'depth': tf.io.FixedLenFeature([], tf.int64),
    'corruption_type': tf.io.FixedLenFeature([], tf.string),
    'severity_level' : tf.io.FixedLenFeature([], tf.int64),
    'class_label': tf.io.FixedLenFeature([], tf.string),
    'image_raw': tf.io.FixedLenFeature([], tf.string),
}
def _parse_image_function(example_proto):
  return tf.io.parse_single_example(example_proto, image_feature_description)

parsed_dataset = raw_dataset.map(_parse_image_function)
first_record = next(iter(parsed_dataset))

# %%
# Print the value of corruption_type column from the first record (image)
print('1. First record corruption type: ', end=' ')
print(first_record['corruption_type'].numpy())

# %%
# Print image
image_raw = first_record['image_raw'].numpy()
display.display(display.Image(data=image_raw))
