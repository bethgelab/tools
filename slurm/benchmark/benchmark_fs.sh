#!/bin/bash
#
#SBATCH --job-name=train-on-imagenet
#SBATCH --error=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.err
#SBATCH --output=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.out 
#SBATCH --time=0-12:00
#
#SBATCH --tasks=1
#SBATCH --array=0-15 #-6
#
#SBATCH --partition=gpu-2080ti-beegfs
#SBATCH --exclude=slurm-bm-29

#SBATCH --cpus-per-task=16
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

function test_writing_reading {
    work_path=$1
    file_size=$2
    logs="$work_path/logs"
    file="$work_path/file"
    destination_folder="$work_path/destination"

    rm -rf "$destination_folder"
    mkdir "$destination_folder"

    while (( $(date +%s) % 300 != 0 )); do
        sleep 0.4
        echo "Sleeping"
    done
    
    # test writing
    start=$(date +%s)
    number_files=0  

    while (( $(date +%s)-start < 150 )); do
        cp "$file" "$destination_folder/file_${number_files}"
        number_files=$((number_files+1))
    done
    finish=$(date +%s)
    fst="$work_path $start $finish Test_type: $file_size Number_of_files: $number_files"
    echo "$fst Writing_time_seconds: $(bc <<< "$finish-$start")" >> "$logs"

    while (( $(date +%s) % 300 != 0 )); do
        sleep 0.4
        echo "Sleeping"
    done

    # test reading
    start=$(date +%s)
    max_number_files=$number_files
    number_files=0
    id=0    
    
    while (( $(date +%s)-start < 150 )); do
        cat "$destination_folder/file_${id}" >> /dev/null
        number_files=$((number_files+1))
        id=$((id+1))

        if (( id == max_number_files )); then
            id=0
        fi
    done
    finish=$(date +%s)
    fst="$work_path $start $finish Test_type: $file_size Number_of_files: $number_files"
    echo "$fst Reading_time_seconds: $(bc <<< "$finish-$start")" >> "$logs"
}

function test_reading_grouped {
    work_path=$1
    file_size=$2
    number_files=$3
    logs="$work_path/logs"
    file="$work_path/file"
    destination_folder="$work_path/destination"
    start=$(date +%s)

    cat "$destination_folder"/* >> /dev/null
    finish=$(date +%s)
    fst="$work_path $start $finish Test_type: $file_size Number_of_files: $number_files"
    echo "$fst Grouped_reading_time_seconds: $(bc <<< "$finish-$start")" >> "$logs"
}

# /scratch = Lustre, (accessible via the Infiniband network)
# work_path=("/home/it4i-gpach/gpach_tuebingen_test"
#                     "/mnt/proj2/dd-21-20/gpach_tuebingen_test"
#                     "/scratch/project/dd-21-20/gpach_tuebingen_test")

# work_path=("/home/bethge/gpachitariu37/gpach_tuebingen_test"
#                     "/mnt/qb/work/bethge/gpachitariu37/gpach_tuebingen_test"
#                     "/mnt/qb/bethge/gpachitariu37/gpach_tuebingen_test")

#path="/home/george/git/tools/slurm/benchmark"
path="/mnt/beegfs/bethge/gpachitariu37/gpach_tuebingen_test"
#paths=("/scratch/project/dd-21-20/gpach_tuebingen_test")

processes=16
r=$RANDOM
experiment_suite_id=$(date +%s)

for a in $(seq $processes); do
    work_path="$path"/test_"$experiment_suite_id"_"$r"_"$a"
    mkdir "$work_path"
done

#sizes=(150K 1M 1G)
sizes=(1G)
#for i in $(seq 0 2); do
for i in 0; do
    for a in $(seq $processes); do
        work_path="$path"/test_"$experiment_suite_id"_"$r"_"$a"
        head -c "${sizes[i]}" < /dev/urandom > "$work_path/file" &
    done
    wait

    for a in $(seq $processes); do
        work_path="$path"/test_"$experiment_suite_id"_"$r"_"$a"
        test_writing_reading "$work_path" "${sizes[i]}" &
    done
    wait

    #for a in $(seq $processes); do
    #    work_path="$path"/test_"$experiment_suite_id"_"$r"_"$a"
    #    test_reading_grouped "$work_path" "${sizes[i]}" "${number_files[i]}" &
    #done
    #wait

    for a in $(seq $processes); do
        work_path="$path"/test_"$experiment_suite_id"_"$r"_"$a"
        rm "$work_path/file"
    done    
done


