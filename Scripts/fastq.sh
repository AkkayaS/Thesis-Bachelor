#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=10:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=fastq_%j.log   # Output file
#SBATCH --error=fastq_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny

# Parameter Usage: 1st parameter - file with accession IDs, 2nd parameter - output directory

# Add the SRA Toolkit installation directory to the PATH
export PATH=$PATH:/dss/dsshome1/05/ge45jet2/sratoolkit.3.1.1-centos_linux64/bin

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <accession_id_file> <output_directory>"
    exit 1
fi

# Get the input file and output directory
accession_file="$1"
output_dir="$2"

# Check if the accession ID file exists
if [ ! -f "$accession_file" ]; then
    echo "Error: File '$accession_file' not found."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"
echo "Output directory: $output_dir"

# Read accession IDs from the file and process each
while IFS= read -r accession_id; do
    if [ -n "$accession_id" ]; then  # Ensure the line is not empty
        #echo "Processing Accession ID: $accession_id"

        # Download the .sra file to the specified output directory
        prefetch "$accession_id" -O "$output_dir"

        # Find the .sra file path
        sra_name=$(find "$output_dir" -name "$accession_id.sra")

        # Check if the .sra file was downloaded successfully
        if [ -z "$sra_name" ]; then
            echo "Error: Failed to download .sra file for $accession_id. Skipping."
            continue
        fi

        # Extract the directory where the .sra file is located
        sra_dir=$(dirname "$sra_name")

        # Convert the .sra file to FASTQ files and save them in the same directory as the .sra file
        fasterq-dump "$sra_name" -O "$sra_dir"

        echo "FASTQ files saved in: $sra_dir"
    fi

done < "$accession_file" 
