#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=10:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=trimming_%j.log   # Output file
#SBATCH --error=trimming_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny

# Check if exactly two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <accession_id_file> <directory>"
    exit 1
fi

# Input file containing accession IDs and output directory
accession_file="$1"
directory="$2"

# Add the required tools to PATH
PATH=$PATH:/dss/dsshome1/05/ge45jet2/

# Check if the accession ID file exists
if [ ! -f "$accession_file" ]; then
    echo "Error: File '$accession_file' not found."
    exit 1
fi

# Read accession IDs from the file and process each
while IFS= read -r accession_id; do
    if [ -n "$accession_id" ]; then  # Ensure the line is not empty
        echo "accession id : $accession_id"
        # Find paired-end files (_1.fastq and _2.fastq)
        fastq_file_one=$(find "$directory/$accession_id" -name "${accession_id}_1.fastq")
        fastq_file_two=$(find "$directory/$accession_id" -name "${accession_id}_2.fastq")
        
        # Find single-end files (ending in .fastq without _1 or _2)
        single_end_file=$(find "$directory/$accession_id" -name "${accession_id}.fastq")
        
        echo "fastq_file_one: $fastq_file_one"
        echo "fastq_file_two: $fastq_file_two"
        echo "single_end_file: $single_end_file"

        # Check if paired-end files exist
        if [ -n "$fastq_file_one" ] && [ -n "$fastq_file_two" ]; then
            echo "Processing paired-end files for $accession_id"
            fastp -i "$fastq_file_one" -I "$fastq_file_two" \
                 -q 20 \
                 -u 30 \
                 -l 50 \
                 --trim_front1 10 \
                 --trim_tail1 10 \
                 -o "$directory/$accession_id/${accession_id}_trimmed_1.fastq" \
                 -O "$directory/$accession_id/${accession_id}_trimmed_2.fastq"
        
        elif [ -n "$single_end_file" ]; then
            # If only single-end file exists
            echo "Processing single-end file for $accession_id"
            fastp -i "$single_end_file" \
                 -o "$directory/$accession_id/${accession_id}_trimmed.fastq"
        else
            echo "No valid FASTQ files found for $accession_id. Skipping."
        fi
    fi
done < "$accession_file"
