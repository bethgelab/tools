#!/bin/bash
#
#SBATCH --job-name=train-on-imagenet
#SBATCH --error=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.err
#SBATCH --output=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.out 
#SBATCH --time=0-12:00
#
#SBATCH --tasks=1
#SBATCH --array=0-99
#
# SBATCH --gres=gpu:1
# SBATCH --partition=gpu-2080ti-preemptable # gpu-2080ti
# SBATCH --cpus-per-task=9
# SBATCH --mem=43750M 

## sacct -j 334811 -o NodeList,State | grep FAILED

set -x # echo on
set -e # exit when any command fails

# scp /home/george/git/tools/slurm/fs_benchmark_karolina.sh it4i-gpach@karolina.it4i.cz:/home/it4i-gpach
# qsub -A DD-21-20 -J 1-100 fs_benchmark.sh
# https://www.altair.com/pdfs/pbsworks/PBSUserGuide2021.1.pdf
# https://code.it4i.cz/training/sc_train_2

# scp /home/george/git/tools/slurm/fs_benchmark_karolina.sh gpachitariu37@slurm:/home/bethge/gpachitariu37

function test {
    absolute_fs_path=$1
    test_type=$2
    number_files=$3

    # Small files test: 1000 files write
    exp_path="$absolute_fs_path/test_dir_files_${task_id}"
    mkdir "$exp_path"

    # Writing
    start=$(date +%s.%N)
    
    for id in $(seq -f'%.0f' "$number_files"); do
        touch "$exp_path/testfile_${id}"
        if [ "$test_type" = "small_files" ]; then
            echo "hello world" > "$exp_path/testfile_${id}"
        else
            cp "$absolute_fs_path/1gb_file_$task_id" "$exp_path/testfile_${id}"
        fi
    done
    finish=$(date +%s.%N)
    echo "$absolute_fs_path Test type: $test_type Number of files: $number_files \
                Writing time (seconds): $(bc <<< "$finish-$start")" >> "$logs"

    # Reading
    start=$finish
    for id in $(seq -f'%.0f' "$number_files"); do
        cat "$exp_path/testfile_${id}" >> /dev/null
    done
    finish=$(date +%s.%N)
    echo "$absolute_fs_path Test type: $test_type Number of files: $number_files \
                Reading time (seconds): $(bc <<< "$finish-$start")" >> "$logs"

    # Deleting
    start=$finish
    rm -r "$exp_path"
    finish=$(date +%s.%N)
    echo "$absolute_fs_path Test type: $test_type Number of files: $number_files \
                Deleting time (seconds): $(bc <<< "$finish-$start")" >> "$logs"
}

task_id=$RANDOM

# /scratch = Lustre, (accessible via the Infiniband network)
karolina_fs_paths=("/home/it4i-gpach/gpach_tuebingen_test"
                    "/mnt/proj2/dd-21-20/gpach_tuebingen_test"
                    "/scratch/project/dd-21-20/gpach_tuebingen_test")
#logs=/home/it4i-gpach/gpach_tuebingen_test/logs/$task_id

tuebingen_fs_paths=("/home/bethge/gpachitariu37/gpach_tuebingen_test"
                                            "/mnt/qb/work/bethge/gpachitariu37/gpach_tuebingen_test"
                                            "/mnt/qb/bethge/gpachitariu37/gpach_tuebingen_test")
logs=/mnt/qb/work/bethge/gpachitariu37/fs_logs/$task_id

echo "Starting time $(date)"  >> $logs

for path in "${tuebingen_fs_paths[@]}"; do
    test "$path" small_files 1000

    if [[ $path != /home*  ]]; then
        head -c 1G < /dev/urandom > "$path/1gb_file_$task_id"
        test "$path" large_files 10
        rm "$path/1gb_file_$task_id"
    fi

    printf "\n" >> $logs
done

