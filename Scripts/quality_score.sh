#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=4:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=quality_score_%j.log   # Output file
#SBATCH --error=quality_score_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny

# Add the required tools to PATH
export PATH=$PATH:/dss/dsshome1/05/ge45jet2/sratoolkit.3.1.1-centos_linux64/bin

# Check if exactly two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <accession_id_file> <input_directory>"
    exit 1
fi

# Input file containing accession IDs and input directory
accession_file="$1"
input_dir="$2"

# Check if the accession ID file exists
if [ ! -f "$accession_file" ]; then
    echo "Error: File '$accession_file' not found."
    exit 1
fi

# Read accession IDs from the file and process each
while IFS= read -r accession_id; do
    if [ -n "$accession_id" ]; then  # Ensure the line is not empty
        fastq_files=$(find "$input_dir/$accession_id" -name "*trimmed*.fastq")

        if [ -n "$fastq_files" ]; then
            echo "Found FASTQ files: $fastq_files"

            # Run FastQC on both FASTQ files
            fastqc $fastq_files
        else
            echo "FASTQ files for $accession_id not found."
        fi
    fi

done < "$accession_file"
