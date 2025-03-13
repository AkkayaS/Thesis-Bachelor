import pandas as pd
import sys

def parse_and_combine_batch_files(batch_files, tx2gene_file):
    """
    Parses batch files, extracts transcript annotations, maps to gene IDs using tx2gene,
    and returns a cleaned dataframe.
    """

    def parse_batch_file(file):
        """Extracts transcript-level annotations and Mercator bin assignments."""
        with open(file, 'r') as f:
            lines = f.readlines()

        data = []
        for line in lines:
            fields = line.strip().split("\t")
            
            # Check if line contains a valid transcript ID
            if len(fields) > 4:
                Transcript_ID = fields[2].replace("'", "")
                name_field = fields[1].replace("'", "")
                mercator_levels = name_field.split(".")
                
                # Extract annotations from DESCRIPTION column
                description = fields[3].replace("'", "")
                annotations = description.split('&')
                prot_scriber_annotation = ''
                swissprot_annotation = ''
                
                for annotation in annotations:
                    key_value = annotation.split(':')
                    if 'prot-scriber' in key_value[0]:
                        prot_scriber_annotation = key_value[1]
                    elif 'swissprot' in key_value[0]:
                        swissprot_annotation = key_value[1]

                # Ensure at least 8 Mercator levels
                while len(mercator_levels) < 8:
                    mercator_levels.append('')
                
                # Append extracted data
                data.append([Transcript_ID] + mercator_levels + [prot_scriber_annotation, swissprot_annotation])

        columns = ["IDENTIFIER"] + [f"level{i}" for i in range(1, 9)] + ["protscriber", "swissprot"]
        return pd.DataFrame(data, columns=columns)
    
    # Parse batch files
    df_list = [parse_batch_file(file) for file in batch_files]
    combined_data = pd.concat(df_list, ignore_index=True)
    
    # Debug: Check initial extracted data
    print("Extracted Data Preview (Before Mapping):")
    print(combined_data.head())
    sys.stdout.flush()

    # Load transcript-to-gene mapping file
    tx2gene = pd.read_csv(tx2gene_file, sep="\t")

    # Remove "transcript:" prefix from IDENTIFIER before merging
    combined_data["IDENTIFIER"] = combined_data["IDENTIFIER"].astype(str).str.replace("transcript:", "", regex=True).str.strip().str.lower()
    
    # Normalize transcript IDs in both dataframes
    tx2gene["Transcript_ID"] = tx2gene["Transcript_ID"].astype(str).str.replace("transcript:", "", regex=True).str.strip().str.lower()
    tx2gene["Gene_ID"] = tx2gene["Gene_ID"].astype(str).str.strip()

    # Merge with tx2gene mapping
    combined_data = combined_data.merge(tx2gene, left_on="IDENTIFIER", right_on="Transcript_ID", how="left")

    # Debug: Check how many identifiers were mapped
    mapped_count = combined_data["Gene_ID"].notnull().sum()
    unmapped_count = combined_data["Gene_ID"].isnull().sum()
    print(f"Successfully mapped transcripts to genes: {mapped_count}")
    print(f"Unmapped transcripts (IDENTIFIER is NaN after merge): {unmapped_count}")
    sys.stdout.flush()

    # Remove rows where merging failed (NaN IDENTIFIERs)
    combined_data = combined_data[combined_data["Gene_ID"].notnull()].copy()

    # Drop old columns and rename IDENTIFIER column
    combined_data.drop(columns=["IDENTIFIER", "Transcript_ID"], inplace=True)
    combined_data.rename(columns={"Gene_ID": "IDENTIFIER"}, inplace=True)

    # Debug: Check cleaned data
    print("Final DataFrame after Mapping:")
    print(combined_data.head())
    print(f"Total valid gene rows: {len(combined_data)}")
    sys.stdout.flush()

    return combined_data

# List of batch files
batch_files = ["/Users/selinakkaya/Downloads/barley.results.txt"]
tx2gene_file = "/Users/selinakkaya/Documents/Bachelor_Arbeit/tx2gene.tsv"

# Parse batch files and map transcripts to genes
barley = parse_and_combine_batch_files(batch_files, tx2gene_file)

# Remove unwanted annotation
barley = barley[barley.level1 != 'No Mercator4 annotation'].drop_duplicates()
barley = barley.drop_duplicates(subset=['IDENTIFIER'])

# List of tables to process
tables = {
    'barley': barley
}
# Columns to process
columns = ["level1", "level2", "level3", "level4", "level5", "level6", "level7", "level8", "protscriber", "swissprot"]
for table_name, table in tables.items():
    for column in columns:
        # Check if the column exists in the table to avoid KeyError
        if column in table.columns:
            # Process the table
            processed_table = table[["IDENTIFIER", column]]
            processed_table = processed_table[processed_table[column].notnull()].drop_duplicates()
            
            # Construct the file name
            filename = f"/Users/selinakkaya/Documents/Bachelor_Arbeit/mercator_{column}_{table_name}.csv"
            
            # Save to CSV
            processed_table.to_csv(filename, sep=',', index=False, header=False)
            print(f"Saved {filename}")
