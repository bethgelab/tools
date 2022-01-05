#! /bin/bash
#
#SBATCH --job-name=my_job
#SBATCH --error=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.err
#SBATCH --output=/mnt/qb/work/bethge/gpachitariu37/logs/%A_%a.out 
#SBATCH --time=1-06:00
#SBATCH --no-requeue
#
#SBATCH --ntasks=3 # this many subtasks will run in parallel
#
#SBATCH --partition=gpu-2080ti
#SBATCH --gpus-per-task=gpu:2
#SBATCH --cpus-per-task=18
#SBATCH --mem-per-task=43750M 

### SBATCH --exclude=slurm-bm-57,slurm-bm-07
### SBATCH --gres=gpu:2

# to run it:
# sbatch sweeper_framework.sh framework_master

set -x # echo on
set -e # exit when any command fails

#####################
##  NOTIFICATIONS  ##
#####################

# change this to your slack/mattermost channel
hook_link=http://134.2.168.15/hooks/ydcu886tf...

function mecho() {
    local message="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}: $1"
    echo "$message" # first print it to logs    
    if ((SLURM_ARRAY_TASK_ID % 10 == 0)); then
        # Only get notifications from a bunch of them.
        curl -i -X POST --data-urlencode "payload={\"text\": \"$message\"}" $hook_link
    fi
}

function malert() {
    local message="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}: :warning: $1"
    curl -i -X POST --data-urlencode "payload={\"text\": \"$message\"}" $hook_link
    echo "$message" # also print to logs
}

function alertfailure() {
    local exit_code=$?
    if ((exit_code != 0)); then
        printf '%s,' "$SLURM_ARRAY_TASK_ID" >> "$CODE_ROOT_FOLDER"/failed
        printf '%s,' "$SLURM_JOB_NODELIST" >> "$CODE_ROOT_FOLDER"/blacklist
        malert "Task failed!"
    fi
}
# Send notification if the job fails (includes failing from syntax errors).
trap "alertfailure" EXIT

function timestamp() {
    date +"%Y-%m-%d %T"
}

source job_train.sh

# this function runs on different nodes
function framework_worker() {
    ##  GPU  ##
    ###########
    export NCCL_DEBUG=INFO
    export PYTHONFAULTHANDLER=1

    for usage in $(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits); do
        if (( usage > 100 )); then 
            malert "$usage MiB are used on GPU from the start. The job will now exit with error"
            exit 1 
        fi
    done

    # Start GPU resource usage monitoring in a background thread. For more info `nvidia-smi dmon -h` and:
    # https://developer.download.nvidia.com/compute/DCGM/docs/nvidia-smi-367.38.pdf.
    # nvidia_log_pid stores the PID of the child process, so it can be killed at the end of this script.
    nvidia_log_file="${SLURM_ARRAY_JOB_ID}"_"${SLURM_ARRAY_TASK_ID}"_nvidia.log
    nvidia-smi --query-gpu=memory.used,memory.free,memory.total,utilization.gpu,utilization.memory, \
               --format=csv --loop=1 --filename=logs/"$nvidia_log_file" & nvidia_log_pid=$!

    job_worker "$@"

    kill -9 $nvidia_log_pid # stop the logging child process
}

function framework_master() {
    job_master
}

# "$@" makes it call the 1st parameter as a function and 
# remaining params as parameters to the function.
# https://stackoverflow.com/a/16159057/4745944
"$@"

# TODO:
# 1. Check for SUCCESS flag and if not present, add node to BLACKLIST and rerun the jobs;


# https://support.ceci-hpc.be/c/_contents/QuickStart/SubmittingJobs/SlurmTutorial.html
# https://stackoverflow.com/questions/46506784/how-do-the-terms-job-task-and-step-relate-to-each-other
