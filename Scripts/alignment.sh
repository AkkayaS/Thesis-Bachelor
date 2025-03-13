#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=10G
#SBATCH --time=24:00:00

# Make sure you have the folder ~/slurm/ for the next lines.
#SBATCH --output=kallisto_alignment_%j.log   # Output file
#SBATCH --error=kallisto_alignment_%j.err    # Error file

# This is where you allocate some of cluster-specific parameters.
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny

# Activate your conda environment with Kallisto
export PATH=$PATH:/dss/dsshome1/05/ge45jet2/.conda/envs/kallisto/bin

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <accession_id_file> <input_directory> <kallisto_index>"
    exit 1
fi

# Input file containing accession IDs, input directory, and Kallisto index
accession_file="$1"
input_dir="$2"
kallisto_index="$3"

# Check if the accession ID file exists
if [ ! -f "$accession_file" ]; then
    echo "Error: File '$accession_file' not found."
    exit 1
fi

# Check if the Kallisto index exists
if [ ! -f "$kallisto_index" ]; then
    echo "Error: Kallisto index file '$kallisto_index' not found."
    exit 1
fi

# Read accession IDs from the file and process each
while IFS= read -r accession_id; do
    if [ -n "$accession_id" ]; then  # Ensure the line is not empty

        # Find the corresponding FASTQ files
        fastq_file_one=$(find "$input_dir/$accession_id" -name "${accession_id}_trimmed_1.fastq")
        fastq_file_two=$(find "$input_dir/$accession_id" -name "${accession_id}_trimmed_2.fastq")
        fastq_file_single=$(find "$input_dir/$accession_id" -name "${accession_id}_trimmed.fastq")

        # Check if paired-end FASTQ files were found
        if [ -n "$fastq_file_one" ] && [ -n "$fastq_file_two" ]; then
            echo "Found paired-end FASTQ files: $fastq_file_one and $fastq_file_two"

            # Create an output directory for this accession ID
            output_dir="$input_dir/$accession_id/kallisto_output"
            mkdir -p "$output_dir"

            # Run Kallisto quantification for paired-end
            kallisto quant \
                -i "$kallisto_index" \
                -o "$output_dir" \
                "$fastq_file_one" "$fastq_file_two"

            echo "Kallisto alignment completed for paired-end accession ID: $accession_id"

        # Check if single-end FASTQ file was found
        elif [ -n "$fastq_file_single" ]; then
            echo "Found single-end FASTQ file: $fastq_file_single"

            # Create an output directory for this accession ID
            output_dir="$input_dir/$accession_id/kallisto_output"
            mkdir -p "$output_dir"

            # Define fragment length and standard deviation (adjust these values as appropriate)
            fragment_length=200  # Example value; change based on your data
            fragment_sd=20       # Example value; change based on your data

            # Run Kallisto quantification for single-end
            kallisto quant \
                -i "$kallisto_index" \
                -o "$output_dir" \
                --single \
                -l "$fragment_length" \
                -s "$fragment_sd" \
                "$fastq_file_single"

            echo "Kallisto alignment completed for single-end accession ID: $accession_id"

        else
            echo "FASTQ files not found for accession ID: $accession_id"
        fi

    fi
done < "$accession_file"
