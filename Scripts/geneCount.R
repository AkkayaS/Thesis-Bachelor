library(readr)
library(dplyr)
library(tximport)
library(rhdf5)
tx2gene <- read_tsv("/dss/dsshome1/05/ge45jet2/tx2gene.tsv")
#head(tx2gene)

#create a vector with file paths of all abundance .h5 files.
files <- list.files(path = "/dss/dssfs03/pn57ba/pn57ba-dss-0001/computational-plant-biology/selin", pattern = "\\.h5$", full.names = TRUE, recursive = TRUE)

# Extract the second-to-last directory (accession ID) (/dss/dssfs03/pn57ba/pn57ba-dss-0001/computational-plant-biology/selin/ERR4704277/kallisto_output/abundance.h5)
sample_names <- basename(dirname(dirname(files)))


names(files) <- sample_names

txi.kallisto <- tximport(files, type = "kallisto",tx2gene= tx2gene, txOut = FALSE)

head(txi.kallisto$counts)

counts <- txi.kallisto$counts

write.csv(counts, "count_table.csv")
