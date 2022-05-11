#!/bin/bash
# Main snakemake job:
# Submits snakemake jobs as individual slurm jobs
# =============================================================================
#SBATCH -p short # Partition or queue. In this case, short!
#SBATCH --job-name=snakemake-make-indices
#SBATCH --mail-type=None # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=much8161@colorado.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1gb
#SBATCH --time=24:00:00 # Time limit hrs:min:sec
#SBATCH --output=/Users/much8161/Repositories/samplot-stix/workflows/log/snakemake-make-indices.out
#SBATCH --error=/Users/much8161/Repositories/samplot-stix/workflows/log/snakemake-make-indices.err
# =============================================================================

# TODO specify disk usage on a per rule basis at least for stix
snakemake -s make-pca-indices.smk \
          --use-conda --conda-frontend mamba \
          --cluster-config conf/cluster_config.yaml \
          --cluster "sbatch -t {cluster.time} \\
                            -N {cluster.nodes} \\
                            -n {cluster.ntasks-per-node} \\
                            -p {cluster.partition} \\
                            --mem={cluster.mem} \\
                            --error {cluster.error}" \
          --jobs 1
