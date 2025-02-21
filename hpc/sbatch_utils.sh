#!/usr/bin/env bash

sbatch_utils::command::srun() {
    echo "------------------------------------------------------------------"
    echo " srun command "
    echo "------------------------------------------------------------------"
    echo -e "srun command is:"
    echo "~"
    echo -e "srun $*"
    echo -e "~\n\n"

    # Execute the Application
    job_starttime=$(date +%s%N)
    srun "$@"
    job_endtime=$(date +%s%N)

    # Calculate and Report Job Runtime
    job_runtime=$(echo "scale=9; (${job_endtime} - ${job_starttime}) / 1000000000" | bc -l)

    echo "------------------------------------------------------------------"
    echo " end of srun command ; runtime = ${job_runtime} seconds"
    echo "------------------------------------------------------------------"
}

sbatch_utils::print::slurm_job_config() {
    echo "------------------------------------------------------------------"
    echo "SLURM Job Configuration:"
    echo "------------------------------------------------------------------"
    printf "%-25s %s\n" "Cluster:" "$SLURM_CLUSTER_NAME"
    printf "%-25s %s\n" "Partition:" "$SLURM_JOB_PARTITION"
    printf "%-25s %s\n" "Number of Nodes:" "$SLURM_JOB_NUM_NODES"
    printf "%-25s %s\n" "Total MPI Tasks:" "$SLURM_NTASKS"
    printf "%-25s %s\n" "CPUs per MPI Task:" "$SLURM_CPUS_PER_TASK"
    printf "%-25s %s\n" "MPI Tasks per Node:" "$SLURM_NTASKS_PER_NODE"
    printf "%-25s %s\n" "Hint:" "$SLURM_HINT"
    printf "%-25s %s\n" "GPUs requested (Total):" "$SLURM_GPUS"
    printf "%-25s %s\n" "GPUs per Node:" "$SLURM_GPUS_PER_NODE"
    printf "%-25s %s\n" "Distribution:" "$J_DISTRIBUTION"
}

sbatch_utils::print::omp_config() {
    echo "------------------------------------------------------------------"
    echo "OpenMP Configuration:"
    echo "------------------------------------------------------------------"
    printf "%-25s %s\n" "OMP Places:" "$OMP_PLACES"
    printf "%-25s %s\n" "OMP Proc Bind:" "$OMP_PROC_BIND"
    printf "%-25s %s\n" "OMP Num Threads:" "$OMP_NUM_THREADS"
}

sbatch_utils::print::module_list() {
    echo "------------------------------------------------------------------"
    echo "loaded modules:"
    echo "------------------------------------------------------------------"
    module list
}

sbatch_utils::end() {
    echo -e "\n--------------------------  END  ---------------------------------"
    echo "End of $SLURM_JOB_NAME ($SLURM_JOB_ID) the $(date)"
    echo -e "------------------------------------------------------------------\n"
}

# create a directory to store all run information (input and output files, including slurm output)
sbatch_utils::create_and_cd_run_dir() {
    local name="$1"
    mkdir "${name}.${SLURM_JOBID}_${SLURM_NNODES}nodes"
    cd "${name}.${SLURM_JOBID}_${SLURM_NNODES}nodes"
}

