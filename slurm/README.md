# Slurm engineering intro 
Hi, this intro contains engineering guidelines and expected performance of common steps in Slurm. Feel free to reach out to me, George, if you have questions or notice problems. 

## 1. Tips & Tricks
1. To run your first Slurm job:

`srun --gres=gpu:1 --partition=gpu-2080ti-interactive singularity exec --nv -B /scratch_local docker://ubuntu echo "Hello world!"`
    
- `--nv` loads the NVIDIA drivers. To check that it worked run `nvidia-smi`;
- `-B /scratch_local` mounts the $SCRATCH folder;

2. Use the `$SCRATCH` folder inside the Slurm job. It's deleted at the end of your job so you don't need to worry about cleaning the files you create on the computing nodes. It's also on SSD drive, so it's fast. 

3. You have (or you can ask for) 2 personal folders. A fast (SSD drive) but smaller one on path `/mnt/qb/home` that is good for small files that you need often (e.g., code). And a slower (HDD drive) but bigger folder on path `/mnt/qb/bethge` that is good for larger files where speed is less important (e.g., checkpoints, saving results, saving a dataset).

## 2. Dataset loading
The datasets are usually stored on the QB machines which are different than the Slurm machines. This means that the dataset needs to be copied over. The best performance was found when rewriting the dataset as a few big files and using the storage format TFRecord from Tensorflow (or RecordIO from MxNet would be good too). This is because in TFRecord and RecordIO the records (images) is stored sequentially which allow for a program to read (stream) continuously. Reading data from disk or streaming data through the network is faster for continuous data. Tensorflow and Pytorch also allow for buffering the data ahead which minimises the pauses caused by waiting for new data to arrive.

Methods tried out to load a dataset on Slurm:
1. Copy over the dataset folder with the images inside in the Slurm job. Duration: 64 minutes. 
2. Put the dataset in a Tar archive. Copy over the Tar in the Slurm job then extract it. Duration: 13m40s: 8m20s download + 5m20s extracting.
3. Have the dataset written in a few big files and use TFRecord from Tensorflow. Duration: 8 minutes.

In both methods 1 and 3 the model can start using the records (images) after the first one is downloaded. So the actual waiting time for the model to train/evaluate decreases to the speed of copying a single record.

Method 3 is much faster than method 1: 8 minutes vs 64 minutes. My assumption is that the difference is because it is slower to send many small files through the network.

In this repository you can find examples on how to convert and read data in TFRecord format. `dataset_loading/convert_dataset_1_data.py` and `dataset_loading/convert_dataset_2_data.py` convert ImageNet-C to TFRecord. And `dataset_loading/read_in_pytorch.py` and `dataset_loading/read_in_tensorflow.py` have examples on how to read the TFRecord files.

More documention on data loading: https://mxnet.apache.org/versions/1.7.0/api/architecture/note_data_loading

### 2.1 Scaling
Slurm scales well when copying a Dataset (this applies to streaming data using TFRecord as well): increasing the Slurm jobs that use the same dataset doesn't increase the time to copy the dataset (overall duration is pretty constant for <50 Slurm jobs).

- Copying a 64 GB dataset (ImageNet-C) from QB storage to 1 Slurm job takes around 6 minutes on average.
- Copying the same 64 GB dataset to 50 paralel jobs takes about the same time (around 6 minutes), and when copying inside 100 parallel jobs it takes closer to 10 minutes.

### 2.2 Speed of dataset streaming vs speed of model processing each batch:
TODO
