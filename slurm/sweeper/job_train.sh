#! /bin/bash

# DATASETS are lazy initialized since it can happen that a task that 
# was finished successfully before is restarted. Then the new run should
# skip copying the dataset.
datasets_initialized=0
function initialise_dataset_lazily() {
    mecho "Copying the datasets locally"
    mkdir "$SCRATCH"/datasets
    tar -xf /mnt/qb/datasets/ImageNet2012.tar -C "$SCRATCH"/datasets
    imagenet_path="$SCRATCH"/datasets/ImageNet2012    
    mecho "Copying finished"

    datasets_initialized=1
}

function archive_checkpoint() {
    local iteration="$1"
    echo "$(timestamp): Starting archiving checkpoint for iteration=$iteration"

    # Move & overwrite new results.
    mv -f "$job_dir"/iteration="$iteration"/checkpoint.pth "$job_dir_archive"/iteration="$iteration"

    echo "$(timestamp): Finished archiving checkpoint for iteration=$iteration"
}

repo_path=/home/bethge/gpachitariu37/git/self-ensemble-visual-domain-adapt-internal

function job_worker() {
    lr=$1
    batch_size=$2
    #echo "lr=$lr, batch_size=$batch_size"
    mecho ":tractor: Worker started!"

    experiment_name=my_test
    experiment_path=$experiment_name/learning_rate=$lr/batch_size=$batch_size/
    job_dir=/mnt/qb/work/bethge/gpachitariu37/jobs/$experiment_path
    job_dir_archive=/mnt/qb/bethge/gpachitariu37/jobs/$experiment_path
    mkdir -p "$job_dir" "$job_dir_archive" # also creates intermediate directories if they don't exist

    for ((iteration=0; iteration<3; iteration++)); do
        iteration_dir="$job_dir"/iteration=$iteration
        if [ -e "$iteration_dir"/success ]; then
            echo "$(timestamp): Found the success flag in $iteration_dir"
            continue # we completed this iteration in a previous job run
        fi
    
        if (( datasets_initialized == 0 )); then
            initialise_dataset_lazily
        fi

        rm -rf "$iteration_dir" # clean previous runs
        mkdir -p "$iteration_dir"         
        
        echo "$(timestamp): Starting iteration=$iteration"
        cp -r "$CODE_ROOT_FOLDER"/dino-internal "$iteration_dir" # copy over the code

        if (( iteration == 0 )); then
            echo "$(timestamp): Copying initial checkpoint to $iteration_dir"
            cp $checkpoint_file "$iteration_dir"/checkpoint.pth
        else
            echo "$(timestamp): Starting training=$iteration"
            # We train for one epoch on ImageNet.
            singularity exec \
                    --nv \
                    -B "$imagenet_c_path":"$imagenet_c_path":ro \
                    docker://pytorch/pytorch \
                python -m torch.distributed.launch \
                    "${dist_pytorch_args[@]}" \
                ...
        fi

        if [ ! -e "$iteration_dir"/knn_"$checkpoint_key".json ]; then
                malert "Job failed! There are no checkpoint!"
                exit 1
        fi
        results=$(sed 's/"//g' "$iteration_dir"/knn_"$checkpoint_key".json | 
                sed 's/,/\n/g' | grep -e "20-NN" -e "val_data_path")
        mecho "iteration=$iteration $results"
    done

    mecho ":green_apple: Job finished!"
}

function job_master() {
    #
    for lr in 0.1 0.2; do
        for batch_size in 32 64 128; do               
            # we call the same current script but with "worker" parameter/function      
            srun sweeper_framework.sh framework_worker $lr $batch_size # &
        done
    done

    wait
}

