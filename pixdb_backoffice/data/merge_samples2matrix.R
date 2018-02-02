################################################################################
#
#   File name: merge_samples2matrix.R
#
#   Authors: Jacek Marzec ( j.marzec@qmul.ac.uk )
#
#   Barts Cancer Institute,
#   Queen Mary, University of London
#   Charterhouse Square, London EC1M 6BQ
#
################################################################################

################################################################################
#
#   Description: Script merging multiple per-sample expression files in user-defined directory into a combined expression matrix.
#
#   Command line use example: Rscript merge_samples2matrix.R --inDir E-GEOD-71729_26343385/norm_files --outFile E-GEOD-71729.merged.txt
#
################################################################################


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

#===============================================================================
#    Functions
#===============================================================================

##### Prepare object to write into a file
prepare2write <- function (x) {
    
    x2write <- cbind(rownames(x), x)
    colnames(x2write) <- c("",colnames(x))
    return(x2write)
}


#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(plotly))
suppressMessages(library(optparse))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--inDir"), action="store", default=NA, type='character',
              help="Directory containing per-sample expression files"),
  make_option(c("-d", "--outFile"), action="store", default=NA, type='character',
              help="Name for the combined expression matrix")
)

opt = parse_args(OptionParser(option_list=option_list))

inFileDir <- opt$inDir
outFile <- opt$outFile


setwd(inFileDir)

file_list <- list.files()

for (file in file_list){
    
    # if the merged dataset doesn't exist, create it
    if (!exists("dataset")){
        dataset <- read.table(file, header=TRUE, sep="\t", row.names=1)
    } else if (exists("dataset")) {
        temp_dataset <-read.table(file, header=TRUE, sep="\t", row.names=1)
        dataset<-cbind(dataset, temp_dataset)
        rm(temp_dataset)
    }
    
}

colnames(dataset) <- file_list

##### Write merged matrix into a file
write.table(prepare2write(dataset), file = outFile, sep="\t", row.names=FALSE)


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

