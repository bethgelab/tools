#!/bin/bash
set -e

# scp /home/george/git/tools/slurm/fs_benchmark_karolina.sh it4i-gpach@karolina.it4i.cz:/home/it4i-gpach

function test {
    absolute_fs_path=$1
    test_type=$2
    number_files=$3
    echo "Test type: $test_type"
    echo "Number of files: $number_files"

    # Small files test: 1000 files write
    exp_path="$absolute_fs_path/test_dir_files"
    mkdir "$exp_path"

    # Writing
    start=$(date +%s.%N)
    
    for id in $(seq -f'%.0f' "$number_files"); do
        touch "$exp_path/testfile_${id}"
        if [ "$test_type" = "small_files" ]; then
            echo "hello world" > "$exp_path/testfile_${id}"
        else
            cp "$absolute_fs_path/1gb_file" "$exp_path/testfile_${id}"
        fi
    done
    finish=$(date +%s.%N)
    echo "Writing time: $(bc <<< "$finish-$start") seconds"

    # Reading
    start=$finish
    for id in $(seq -f'%.0f' "$number_files"); do
        cat "$exp_path/testfile_${id}" >> /dev/null
    done
    finish=$(date +%s.%N)
    echo "Reading time: $(bc <<< "$finish-$start") seconds"

    start=$finish
    rm -r "$exp_path"
    finish=$(date +%s.%N)
    echo "Deleting time: $(bc <<< "$finish-$start") seconds"
}

# /scratch = Lustre, (accessible via the Infiniband network)

fs_paths=("/home/it4i-gpach/gpach_tuebingen_test"
                    "/mnt/proj2/dd-21-20/gpach_tuebingen_test"
                    "/scratch/project/dd-21-20/gpach_tuebingen_test")

for path in "${fs_paths[@]}"; do
    echo "Path=$path"

    test "$path" small_files 1000

    head -c 1G < /dev/urandom > "$path"/1gb_file
    test "$path" large_files 10
    rm "$path"/1gb_file

    printf "\n"
done

