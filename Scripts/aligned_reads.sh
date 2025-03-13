#!/bin/bash

# Define the main directory containing subdirectories with accession IDs
main_dir="/dss/dssfs03/pn57ba/pn57ba-dss-0001/computational-plant-biology/selin"

# Define the text file containing the list of accession IDs (one per line)
accession_file="/dss/dsshome1/05/ge45jet2/sra_file"

# Output CSV file
output_file="/dss/dssfs03/pn57ba/pn57ba-dss-0001/computational-plant-biology/selin/alignment_summary.csv"

# Write the header to the output file
echo "AccessionID,ReadsProcessed,ReadsPseudoaligned,PseudoalignmentRate(%)" > "$output_file"

# Loop through each accession ID from the text file
while read -r accession_id; do
    # Construct the path to the kallisto_output directory
    kallisto_dir="$main_dir/$accession_id/kallisto_output"

    # Path to the run_info.json file
    json_file="$kallisto_dir/run_info.json"

    # Check if the run_info.json file exists
    if [ -f "$json_file" ]; then
        # Extract fields using jq
        reads_processed=$(jq '.n_processed' "$json_file")
        reads_pseudoaligned=$(jq '.n_pseudoaligned' "$json_file")
        pseudoalignment_rate=$(jq '.p_pseudoaligned * 100' "$json_file")

        # Append data to the output file
        echo "$accession_id,$reads_processed,$reads_pseudoaligned,$pseudoalignment_rate" >> "$output_file"
    else
        echo "Warning: run_info.json not found for $accession_id" >&2
    fi
done < "$accession_file"

echo "Alignment statistics saved to $output_file"
