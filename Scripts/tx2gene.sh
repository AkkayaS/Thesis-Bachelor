#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir output_file"
    exit 1
fi

dir=$1
output_file=$2

# Create or clear the output file
echo -e "Sample\tTranscript_ID\tGene_ID" > "$output_file"

# Iterate through all abundance.tsv files in the subdirectories
find "$dir" -type f -name "abundance.tsv" | while read -r file; do
    # Extract the subdirectory name as the sample name
    sample_name=$(basename "$(dirname "$file")")

    echo "Processing file: $file (Sample: $sample_name)"

    # Process the file and append to the output file
    awk -v sample="$sample_name" 'NR > 1 {  # Skip the header
        transcript_id = $1
        gene_id = transcript_id
        sub(/\.[0-9]+$/, "", gene_id)  # Remove the .1, .2, etc., suffix
        print sample "\t" transcript_id "\t" gene_id
    }' "$file" >> "$output_file"
done

