# year_month_day__hour_minute_second
DATE=`date '+%Y_%m_%d__%H_%M_%S'`

# upload the current folder to jobs/job_$DATE on slurm head-node
rsync -r . gpachitariu37@slurm:jobs/job_$DATE

ssh gpachitariu37@slurm '    
    srun --pty --gres=gpu:1 --partition=gpu-2080ti-interactive \
        -B /scratch_local -B jobs/job_'$DATE' \
        -B /mnt/qb/datasets/ \
        -B /mnt/qb/bethge/gpachitariu37/datasets \
        singularity exec --nv docker://pytorch/pytorch \
        bash echo Hi
    '