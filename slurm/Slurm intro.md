# Slurm performance intro 
This intro contains engineering guidelines and performance of common steps in Machine Learning. If the results you get in reality are very different from these estimations, please reach out to me, George.

There is first a summary of the best results (guidelines) and afterwards the experiments tried and explanations.

### Summary
Slurm numbers:
- Copying a 1 GB file from QB storage to Slurm job: 7 seconds;
- Prediction time on Resnet on local 1 GB TFRecord file on gpu-2080ti: TODO seconds;

The bove numbers are useful to do back of of the envelope calculations:
1. How long will it take to copy a 100 GB dataset? (Answer: around 7 * 100 seconds)
2. How long will it it take for Feedforward on the entire ImageNet? (Answer: TODO)
 


### 1. Dataset loading
The Problem is that the dataset is not on the same machine where the slurm job is, so it needs to be copied over (accessed) somehow. The best performance was found when rewriting the dataset in a few big files and using TFRecord from Tensorflow. This is because TFRecord (like RecordIO from MxNet) are formats create to store data, like images, in continous files. Streaming data from Disk or streaming through network is faster for continous files. 

There are multiple designs choices that reduce the total duration overhead caused by loading data to close to 0 seconds:
- data loading is faster than predicting (or training) and it runs on different threads;
- Tensorflow and Pytorch allow for buffering the data ahead; 

The experiments tried out:
1. Copy over the dataset folder with the images inside in the Slurm job. Duration: 64 minutes. 
2. Put the dataset in a Tar archive. Copy over the Tar in the Slurm job then extract it. Duration: 13.6 minutes (8m23s download + 5m21s extracting).   
3. Have the dataset written in a few big files and use TFRecord from Tensorflow. Duration: TODO minutes.

Here (link) there is an example to convert a dataset into TFRecord and read it in PyTorch or Tensorflow.

More documention on data loading: https://mxnet.apache.org/versions/1.7.0/api/architecture/note_data_loading
