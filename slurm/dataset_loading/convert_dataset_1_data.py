"""
To run this:
srun --pty --partition=gpu-2080ti-interactive singularity exec  \
    -B /mnt -B /mnt/qb/bethge/gpachitariu37/datasets \
    docker://tensorflow/tensorflow \
    python /home/bethge/gpachitariu37/imagenetc_convert_dataset.py \
    /mnt/qb/datasets/ImageNet-C /mnt/qb/bethge/gpachitariu37/datasets/imagenet_c
"""

import os, sys
import tensorflow as tf

def _int64_feature(value):
    return tf.train.Feature(int64_list=tf.train.Int64List(value=[value]))

def _bytes_feature(value):
    # works for byte and string
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))

if __name__ == "__main__":
    imagenet_c_folder = str(sys.argv[1])
    output_folder = str(sys.argv[2])

    for corruption_type in os.listdir(imagenet_c_folder):
        corruption_type_folder = imagenet_c_folder + '/' + corruption_type
        
        for severity_level in os.listdir(corruption_type_folder):
            severity_level_folder = corruption_type_folder + '/' + severity_level

            record_file = output_folder + '/' + \
                            corruption_type + '_' + severity_level + '.tfrecords'
            with tf.io.TFRecordWriter(record_file) as writer:

                for class_label in os.listdir(severity_level_folder):
                    class_label_folder = severity_level_folder + '/' + class_label

                    for image_name in os.listdir(class_label_folder):
                        image_bytes = open(class_label_folder+'/'+image_name, 'rb').read()

                        image_shape = tf.image.decode_jpeg(image_bytes).shape
                        feature = {
                            'height': _int64_feature(image_shape[0]),
                            'width': _int64_feature(image_shape[1]),
                            'depth': _int64_feature(image_shape[2]),
                            'corruption_type': _bytes_feature(corruption_type.encode('utf-8')),
                            'severity_level' : _int64_feature(int(severity_level)),
                            'class_label': _bytes_feature(class_label.encode('utf-8')),
                            'image_name': _bytes_feature(image_name.encode('utf-8')),
                            'image_raw': _bytes_feature(image_bytes),
                        }
                        tf_example = tf.train.Example(features=tf.train.Features(feature=feature))
                        writer.write(tf_example.SerializeToString())





