#title           :retrieve_datasets_from_pmids.R
#description     :this script automatically retrieve GEO datasets from a list of PMIDS
#author          :Stefano Pirro'
#date            :20170306
#version         :0.2
#usage           :Rscript retrieve_datasets_from_pmids.R <pmids_file>
#notes           :
#==============================================================================

### PARAMETERS #######################################################
suppressMessages(library(optparse))
suppressMessages(library(ArrayExpress))
suppressMessages(library(XML))
suppressMessages(library(httr))

options(warn=-1)

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-p", "--pmid"), action="store", default=NA, type='character',
              help="pmid to process from array express")
)

opt = parse_args(OptionParser(option_list=option_list))
pmid = opt$pmid
data_type = 'data'

#-- creating root directories --#
current_dir = getwd()
root_dir = paste(current_dir,data_type,sep = "/")
dir.create(root_dir)
# dir for XML files (downloaded from ArrayExpress)
xml_dir = paste(root_dir,'xml',sep = '/')
dir.create(xml_dir)
# ---------------------------- #

# creating array where to store all generated folders for further analyses
list_folders = c()

#-- extract ArrayExpress information for provided PMID --#

## download xml file
url_xml = paste('http://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?pmid=',pmid,sep='')
xml_file_name = paste(pmid,'.xml',sep = '')
try(download.file(url_xml,destfile = paste(xml_dir,xml_file_name,sep = '/'), method = 'auto',cacheOK = FALSE,quiet = TRUE))

### initialising download report file ###
report_download_filename = paste(root_dir,'download_report.txt', sep = '/')
### initialising download report flag ###
report_download_flag = 0

### managing xml file
  xml_stream <- xmlParse(paste(xml_dir,xml_file_name,sep = '/'))
  xml_data <- xmlToList(xml_stream)

  ## update: extracting Array Express Accessions for multiple series
  # extracting Array Express Accession (if available, else NA assigned)
  array_express_acc = array()
  for (i in 1:length(xml_data)) {
    array_express_acc[i] = tryCatch(
      {
        xml_data[[i]]$accession
      },
      error=function(cond) {
        return(NA)
      }
    )
  }

  if (length(array_express_acc) > 0) {
    #- downloading complete ArrayExpress data -#
    # creating subdirectory <ArrayExpressAccession>_<PMID>
    for (acc in array_express_acc) {
      if (!is.na(acc)) {
          subdir_name = paste(root_dir,paste(acc,pmid,sep='_'),sep = '/')
          dir.create(subdir_name)

          # write the file with generated subdir
          report_filename = paste(root_dir,'downloaded_genesets.txt', sep = '/')
          write(subdir_name, file = report_filename, sep = '\n', append = TRUE)

          # getting complete files
          getAE(acc, path = subdir_name, type = "processed", extract = FALSE)
          ### UPDATE 2017/06/2017 -- downloading just adf file and sdrf to speedup download
          #adf_filename = paste(subdir_name,"/",acc,".adf.txt",sep="")
          #sdrf_filename = paste(subdir_name,"/",acc,".sdrf.txt",sep="")
          #adf_url = paste("https://www.ebi.ac.uk/arrayexpress/files/",acc,"/",acc,".adf.txt",sep="")
          #sdrf_url = paste("https://www.ebi.ac.uk/arrayexpress/files/",acc,"/",acc,".sdrf.txt",sep="")

          #GET(adf_url, write_disk(adf_filename))
          #GET(sdrf_url, write_disk(sdrf_filename))

          # extracting all processed files into the same folder
          norm_dir = paste(subdir_name,'norm_files',sep = '/')
          dir.create(norm_dir)

          # extracting all raw (cel for Illumina/Affymetrix and txt for Agilent) files into the same folder (for normalized matrix creation)
          #cel_dir = paste(subdir_name,'cel',sep = '/')
          #dir.create(cel_dir)
          #system(paste("find . -name '*.raw.*.zip' | xargs -n1 unzip -d ",cel_dir,'/',sep = ''))

          # update 2017/03/29 -- extracting and manipulating the ADF file (Array Design, to map probes and genes, independently on the platform)
          ## getting Array Design Name ##
          setwd(subdir_name)
          system("for file in $(find . -name '*.adf.txt'); do head -1 $file >> array_technology.txt; done")
          system("for file in $(find . -name '*.adf.txt'); do csplit -sf tmp -n 1 $file /main/+1 && mv tmp1 $file && rm tmp0; done")

          #### UPDATE 2017/04/26 -- merging all the adf files into one and writing into a final dictionary file ####
          adf_files <- list.files(".", pattern = "*.adf.txt")
          final_adf = data.frame()
          cont = 0
          for(adf.fn in adf_files) {
              if (cont == 0) {
                  final_adf = read.table(adf.fn, header = T, sep = '\t', stringsAsFactors = F, fill = T)
              } else {
                  adf.df = read.table(adf.fn, header = T, sep = '\t', stringsAsFactors = F, fill = T)
                  common_columns <- intersect(colnames(adf.df), colnames(final_adf))
                  final_adf = rbind(
                      adf.df[, common_columns],
                      final_adf[, common_columns]
                  )
              }
              cont=cont+1
          }

          final_adf <- final_adf[!duplicated(final_adf[1]),]

          # writing final file
          write.table(final_adf, file = "array.design.final.adf", sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
          #### ------------------------------------------------------------------------------- ####

          #### UPDATING DOWNLOAD REPORT FLAG####
          report_download_flag = 1
        }
      }

      ### UPDATING DOWNLOAD REPORT according to flag value
      if (report_download_flag == 0) {
          write(paste(pmid,"failed",sep="\t"), file = report_download_filename, sep = '\n', append = TRUE)
      } else {
          write(paste(pmid,"ok",sep="\t"), file = report_download_filename, sep = '\n', append = TRUE)
      }

    } else {

    #### UPDATING DOWNLOAD REPORT ####
    write(paste(pmid,"failed",sep="\t"), file = report_download_filename, sep = '\n', append = TRUE)
  }
