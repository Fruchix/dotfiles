#!/usr/bin/env bash
#SBATCH --exclusive
#SBATCH --output=run_%x-%j.out
#SBATCH --account=
#SBATCH --partition=
#SBATCH --time=
#SBATCH --nodes=
#SBATCH --ntasks-per-node=

# ================================= JOB SETUP =================================
. sbatch_utils.sh
sbatch_utils::create_and_cd_run_dir "run_name"

# =========================== PRINT JOB ENVIRONMENT ===========================
sbatch_utils::print::slurm_job_config


# ================================= RUN SETUP =================================

### copy required files for run ###

### load modules ###

### export env variables ###

# OMP
# export OMP_PLACES=sockets               #  = threads | cores | sockets (corresponds to NUMA)
# export OMP_PROC_BIND=true               #  = true    | close | spread | master | false
# export OMP_NUM_THREADS=2                #  = 1       | 64    | ${SLURM_CPUS_PER_TASK}

# Interconnect
# export UCX_TLS=rc_x,sm,self

### app information ###
APP_EXE="exe_path"
APP_FLAGS=""

### SLURM Execution Flags used to launch the srun command ###
SLURM_FLAGS=(
    --nodes=2
    --ntasks=2
    --ntasks-per-node=1
    # --cpus-per-task="${OMP_NUM_THREADS}"  # or -c : number of CPUs per MPI task, care hypertread
    # --hint=nomultithread                  # disable multithread, has to be in both srun/sbatch
    # --distribution=block:block          # node and mpi tasks binding
    # --gpus-per-node=8                   # number of GPUs required per allocated node
    # --ntasks-per-socket=16              # mpi task limit per socket
)

# print env variables
echo "------------------------------------------------------------------"
echo "ENV VARIABLES"
echo "------------------------------------------------------------------"
echo "UCX_TLS=${UCX_TLS}"
echo "MPI_HOME=${MPI_HOME}"

sbatch_utils::command::srun "${SLURM_FLAGS[@]}" "${APP_EXE}" "${APP_FLAGS}"

# =============================== PRINT JOB END ===============================
sbatch_utils::end
