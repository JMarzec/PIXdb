### bcntb.map.R ###
### DESCRIPTION ########################################################
# This script map probes inside the expression matrix
# to both Ensembl Gene IDs and Gene names and save them into separate files

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/05/08			Stefano					starting from the scratch

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(source(paste(current_dir,"scripts/bcntb.functions.R",sep = "/")))
suppressMessages(library(optparse))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-a", "--adf_file"), action="store", default=NA, type='character',
              help="File containing array design data"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory for output")
)

opt = parse_args(OptionParser(option_list=option_list))

# reading array design file
adf.data = read.table(file = opt$adf_file, sep = "\t", header = TRUE, fill = TRUE, row.names = 1, stringsAsFactors = FALSE)

# readind ensembl - gene_name dictionary
ensembl.gn.file = paste(current_dir,"support_files/ensembl_gn_dict.csv",sep = "/")
ensembl.gn = read.table(file = ensembl.gn.file, sep = ",", header = TRUE, fill = TRUE, stringsAsFactors = FALSE)

# splitting exp_file string to retrieve all the experimental samples
exp_files = unlist(strsplit(opt$exp_file, ","))

for (j in 1:length(exp_files)) {
    # pasting the right directory to open the expression data file
    ef = paste(opt$dir,"norm_files",exp_files[j],sep = "/")
    exp.data <- read.table(file = ef, header = T, sep = "\t", stringsAsFactors = FALSE, row.names = NULL)
    #exp.data <- read.table(file = opt$exp_file, header = T, sep = "\t", stringsAsFactors = FALSE, row.names = NULL)
    colnames(exp.data)[1] <- 'probe_name'
  
    # assign Ensembl id to most variable probes (code edited fromn bcntb.utils.eg.R)
    # MappingProbes function takes as input:
    #   - the expression matrix (exp.data)
    #   - the array design file (ArrayExpress file)
    #   - type of mapping ("ensembl", "entrez", "gene_name")
    #   - ensembl-gene_name dictionary (just for "gene_name" flag)
    probes_entrez <- MappingProbes(exp.data, adf.data, "entrez", "")
    probes_ensembl <- MappingProbes(exp.data, adf.data, "ensembl", "")
    probes_genename <- MappingProbes(exp.data, adf.data, "gene_name", ensembl.gn)
    
    # --- filter expr data by most variable probes --- #
      # We perform this operation for ensembl, entrez and gene_name mappings
      exp.data.filtered.ensembl <- merge(probes_ensembl, exp.data, by.x = 'probe_name')
      exp.data.filtered.ensembl$probe_name <- NULL # here we delete the corrensponding probe_name column
  
      ### UPDATE 2017/05/10 -- Missing Ensembl Gene IDs for some Breast Cancer Receptors (ESR1, PGR, ERBB2)
      # need assign entrez id to most variable probes (code edited fromn bcntb.utils.eg.R) in order to execute Mclust method.
      exp.data.filtered.entrez <- merge(probes_entrez, exp.data, by.x = 'probe_name')
      exp.data.filtered.entrez$probe_name <- NULL # here we delete the corrensponding probe_name column
      
      # gene_name mapping
      exp.data.filtered.genename <- merge(probes_genename, exp.data, by.x = 'probe_name')
      exp.data.filtered.genename$probe_name <- NULL # here we delete the corrensponding probe_name column
    # --- ---------------------------------------- --- # 
    
    # --- writing the filtered datasets into csv file --- #
      # Initializing file names #
        ef.ensembl = paste(opt$dir,"/norm_files/",substr(exp_files[j], 1, nchar(exp_files[j])-4),".ensembl.csv", sep = "")
        ef.entrez = paste(opt$dir,"/norm_files/",substr(exp_files[j], 1, nchar(exp_files[j])-4),".entrez.csv", sep = "")
        ef.genename = paste(opt$dir,"/norm_files/",substr(exp_files[j], 1, nchar(exp_files[j])-4),".genename.csv", sep = "")
      # --- ---------------- ---#
      
      # Writing files #
        write.table(exp.data.filtered.ensembl, file=ef.ensembl, sep = '\t', col.names = TRUE, row.names = FALSE, quote = FALSE, eol = '\n')
        write.table(exp.data.filtered.entrez, file=ef.entrez, sep = '\t', col.names = TRUE, row.names = FALSE, quote = FALSE, eol = '\n')
        write.table(exp.data.filtered.genename, file=ef.genename, sep = '\t', col.names = TRUE, row.names = FALSE, quote = FALSE, eol = '\n')
      # --- ------ ---#
}