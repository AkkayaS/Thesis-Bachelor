#!/bin/bash

# Load MultiQC environment
export PATH=$PATH:/dss/dsshome1/05/ge45jet2/.conda/envs/multiqc-env/bin

# Usage check
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <err_file> <output_dir>"
    exit 1
fi

err_file="$1"
output_dir="$2"

# Generate MultiQC report for the specified `.err` file
multiqc -f -v -o "$output_dir" "$err_file"



