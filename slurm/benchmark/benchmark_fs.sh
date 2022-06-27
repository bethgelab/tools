#!/bin/bash
#
#SBATCH --job-name=train-on-imagenet
#SBATCH --error=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.err
#SBATCH --output=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.out 
#SBATCH --time=0-12:00
#
#SBATCH --tasks=1
#SBATCH --array=0 #-6
#
#SBATCH --partition=gpu-2080ti-beegfs
#SBATCH --exclude=slurm-bm-29

#SBATCH --cpus-per-task=37
#SBATCH --mem=43750M 

# ### SBATCH --nodelist=slurm-bm-79 # bethge
# ### SBATCH --gres=gpu:1

set -x # echo on
set -e # exit when any command fails

# scp /home/george/git/tools/slurm/fs_benchmark_karolina.sh it4i-gpach@karolina.it4i.cz:/home/it4i-gpach
# qsub -A DD-21-20 -J 1-100 fs_benchmark.sh
# https://www.altair.com/pdfs/pbsworks/PBSUserGuide2021.1.pdf
# https://code.it4i.cz/training/sc_train_2

# scp /home/george/git/tools/slurm/benchmark_fs.sh gpachitariu37@slurm:/home/bethge/gpachitariu37

function test_writing {
    work_path=$1
    file_size=$2
    number_files=$3
    logs="$work_path/logs"
    file="$work_path/file"
    destination_folder="$work_path/destination"

    rm -rf "$destination_folder"
    mkdir "$destination_folder"
    
    # Writing
    start=$(date +%s.%N)
    
    for id in $(seq "$number_files"); do
        cp "$file" "$destination_folder/file_${id}"
    done
    finish=$(date +%s.%N)
    echo "$work_path $start $finish Test type: $file_size Number of files: $number_files \
                Writing time (seconds): $(bc <<< "$finish-$start")" >> "$logs"
}

function test_reading {
    work_path=$1
    file_size=$2
    number_files=$3
    logs="$work_path/logs"
    file="$work_path/file"
    destination_folder="$work_path/destination"
    start=$(date +%s.%N)

    for id in $(seq "$number_files"); do
        cat "$destination_folder/file_${id}" >> /dev/null
    done
    finish=$(date +%s.%N)
    echo "$work_path $start $finish Test type: $file_size Number of files: $number_files \
                Reading time (seconds): $(bc <<< "$finish-$start")" >> "$logs"
}

function test_reading_grouped {
    work_path=$1
    file_size=$2
    number_files=$3
    logs="$work_path/logs"
    file="$work_path/file"
    destination_folder="$work_path/destination"
    start=$(date +%s.%N)

    cat "$destination_folder"/* >> /dev/null
    finish=$(date +%s.%N)
    echo "$work_path $start $finish Test type: $file_size Number of files: $number_files \
                Grouped Reading time (seconds): $(bc <<< "$finish-$start")" >> "$logs"

}

function run {
    work_path="$1"
    logs="$work_path/logs"
    mkdir "$work_path"
    
    #sizes=(150K 1M 1G)
    #number_files=(1000 200 10)
    sizes=(1G)
    number_files=(10)
    #for i in $(seq 0 2); do
    for i in 0; do
        echo "Starting time for ${sizes[i]} $(date)"  >> "$logs"
        head -c "${sizes[i]}" < /dev/urandom > "$work_path/file"
        test "$work_path" "${sizes[i]}" "${number_files[i]}"

        printf "\n" >> "$logs"
        rm "$work_path/file"
    done
}


# /scratch = Lustre, (accessible via the Infiniband network)
# work_path=("/home/it4i-gpach/gpach_tuebingen_test"
#                     "/mnt/proj2/dd-21-20/gpach_tuebingen_test"
#                     "/scratch/project/dd-21-20/gpach_tuebingen_test")

# work_path=("/home/bethge/gpachitariu37/gpach_tuebingen_test"
#                     "/mnt/qb/work/bethge/gpachitariu37/gpach_tuebingen_test"
#                     "/mnt/qb/bethge/gpachitariu37/gpach_tuebingen_test")

paths=("/mnt/beegfs/bethge/gpachitariu37/gpach_tuebingen_test")

#paths=("/home/george/git/tools/slurm/benchmark")
experiment_suite_id=$(date +%s)

for path in "${paths[@]}"; do
    r=$RANDOM
    for a in $(seq 56); do
        run "$path"/test_"$experiment_suite_id"_"$r"_"$a" &
    done
    wait
done
