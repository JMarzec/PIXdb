### bcntb.estimate.R ###
### DESCRIPTION ########################################################
# This script evaluates tumor purity by applying
# 'estimate' R package on an expression matrix

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/04/19			Stefano					optimized from 'bcntb.apply.estimate.R' Emanuela's version

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(source(paste(current_dir,"bcntb.functions.R",sep = "/")))
suppressMessages(library(estimate))
suppressMessages(library(optparse))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format (file with indicated CANCER samples"),
  make_option(c("-t2", "--target2"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format to which the estimate output is to be written"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

# loading sources
ann.data <- read.table(file = opt$target, header = T, sep = "\t")
ann.data$File_name <- make.names(ann.data$File_name)

# splitting annotation data by category (cancer, normal, unknown)
ann.data.splitted <- split(ann.data, ann.data$Target)
exp_files = unlist(strsplit(opt$exp_file, ",")) # splitting exp_file string to retrieve all the identified samples

# creating tumor purity dataframe (useful for updating the final target file) -- empty for now
tumor_purity_df <- data.frame("File_name"=character(), "TumorPurity"=numeric())

# creating tumor purity dataframe full (useful for creating interactive plots) -- empty for now
tumor_purity_full_df <- data.frame("File_name"=character(),
                              "StromalScore"=numeric(),
                              "ImmuneScore"=numeric(),
                              "ESTIMATEScore"=numeric(),
                              "TumorPurity"=numeric()
                              )

for (j in 1:length(exp_files)) {
    ef = paste(opt$dir,"norm_files",exp_files[j],sep = "/")
    exp.data <- read.table(file = ef, header = T, sep = "\t", stringsAsFactors = FALSE, row.names = NULL)

    ### Apply 'Estimate' calculations just to cancer group ###
    if (length(as.character(ann.data.splitted$cancer$File_name)) > 0) {
      selected_samples <- intersect(as.character(ann.data.splitted$cancer$File_name),colnames(exp.data))
      exp.data.category.subset <- as.data.frame(t(scale(t(data.matrix(subset(exp.data[,-1], select = selected_samples))))))
      rownames(exp.data.category.subset) = exp.data$Entrez.ID
      # writing expression data filtered on a tmp file (needed by estimate package)
      exp.data.fn = paste(opt$dir,'exp.data.txt',sep="/")
      write.table(exp.data.category.subset,file=exp.data.fn,row.names=T,col.names = T,sep="\t",quote=F)

      estfile = paste(opt$dir,"/common.genes.estimate.gct",sep="")
      scrfile = paste(opt$dir,"/estimate.score.gct",sep="")

      filterCommonGenes(exp.data.fn, estfile, id = "EntrezID")
      suppressMessages(estimateScore(estfile, output.ds=scrfile))

      # Change the output to update the target file and also to improve the output
      estimate.output=read.table(file=scrfile,sep="\t",skip=2,header=T,row.names=1)

      ### updating tumor purity dataframe ###
      tmp.purity.df = data.frame('File_name'=colnames(estimate.output[,-1]), 'TumorPurity'=as.numeric(estimate.output[4,-1]))
      tumor_purity_df <- rbind(tumor_purity_df, tmp.purity.df)

      ### updating tumor purity full dataframe ###
      tmp.purity.full.df = data.frame('File_name'=colnames(estimate.output[,-1]),
                                      'StromalScore'=round(as.numeric(estimate.output[1,-1]), digits = 2),
                                      'ImmuneScore'=round(as.numeric(estimate.output[2,-1]), digits = 2),
                                      'ESTIMATEScore'=round(as.numeric(estimate.output[3,-1]), digits = 2),
                                      'TumorPurity'=round(as.numeric(estimate.output[4,-1]), digits = 2)
                                      )
      tumor_purity_full_df <- rbind(tumor_purity_full_df, tmp.purity.full.df)
    }
}

## writing estimate report into file (useful for live plotting function)
  #### initialising the filename and directory where to save the report
  estimate.report.filename = paste(opt$dir, 'estimate.report', sep = "/")
  #### writing estimate into file
  estimate.report = tumor_purity_full_df[complete.cases(tumor_purity_full_df),] # removing rows with NA value
  estimate.report.file = write.table(estimate.report, file = estimate.report.filename, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

#write out tumour purity to target file
# loading the target file where the tumour purity will be added
ann.data2 <- read.table(file = opt$target2, header = T, sep = "\t")
ann.data2$File_name <- make.names(ann.data2$File_name)

ann.data.updated <- merge(ann.data2, tumor_purity_df, by.x = "File_name", all=TRUE)
#ann.data.updated <- ann.data.updated[c(2,1,3:ncol(ann.data.updated))]
#print(ann.data.updated)
write.table(ann.data.updated, file=opt$target2, sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE, eol = "\n")
