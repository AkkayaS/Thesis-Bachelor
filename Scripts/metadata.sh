#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=8:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=meta_data%j.log   # Output file
#SBATCH --error=meta_data_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny

# Add the required tools to PATH
export PATH=$PATH:/dss/dsshome1/05/ge45jet2/sratoolkit.3.1.1-centos_linux64/bin

# Check if exactly two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <accession_id_file> <directory>"
    exit 1
fi

# Input file containing accession IDs and output directory
accession_file="$1"
directory="$2"

# Check if the accession ID file exists
if [ ! -f "$accession_file" ]; then
    echo "Error: File '$accession_file' not found."
    exit 1
fi

# Read accession IDs from the file and process each
while IFS= read -r accession_id; do
    if [ -n "$accession_id" ]; then  # Ensure the line is not empty
        # Fetch metadata information for each accession_id and save it in the corresponding directory
        mkdir -p "$directory/$accession_id"  # Ensure the directory exists
        esearch -db sra -query "$accession_id" | efetch -format runinfo > "$directory/$accession_id/metadata.csv"
    fi

done < "$accession_file"
