#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=5:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=kallisto_indexing_%j.log   # Output file
#SBATCH --error=kallisto_indexing_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny


export PATH=$PATH:/dss/dsshome1/05/ge45jet2/.conda/envs/kallisto/bin

# Check input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <transcriptome_fasta> <kallisto_index>"
    echo "Example: $0 transcriptome.fa kallisto_index.idx "
    exit 1
fi

# Input parameters
transcriptome_fasta="$1"  # Path to the transcriptome FASTA file
kallisto_index="$2"       # Path to save the Kallisto index            

# Create Kallisto index
echo "Constructing Kallisto index..."
kallisto index -i "$kallisto_index"  "$transcriptome_fasta"

if [ $? -eq 0 ]; then
    echo "Kallisto index successfully created: $kallisto_index"
else
    echo "Error: Failed to create Kallisto index."
    exit 1
fi
