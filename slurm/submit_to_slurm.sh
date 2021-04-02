# year_month_day__hour_minute_second
DATE=`date '+%Y_%m_%d__%H_%M_%S'`

# upload the current folder to jobs/job_$DATE on slurm head-node
rsync -r . gpachitariu37@slurm:jobs/job_$DATE

#COMMAND="python jobs/job_$DATE/test.py"
COMMAND="bash"

ssh gpachitariu37@slurm '    
    srun --pty --gres=gpu:1 --partition=gpu-2080ti-interactive \
        singularity exec --nv docker://pytorch/pytorch '"$COMMAND"'    '
'
