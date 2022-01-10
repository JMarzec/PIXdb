################################################################################
#
#   File name: PCA.R
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
#   Description: Script performing principal component analysis using normalised expression data. It generates 3-dimensional plot of user-defined principal component and two . NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: R --file=./PCA.R --args "CCLE_PC_processed_mRNA.txt" "CCLE_PC_target.txt" "Target" "1" "Example_results/PC_PCA"
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Third arg:      Variable from the samples annotation file to be used for samples colouring
#   Forth arg:      The principal component to be plotted together with the two subsequent most prevalent principal components
#   Fifth arg:      Full path with name of the output folder
#
################################################################################

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

#===============================================================================
#    Functions
#===============================================================================

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

##### Assign colours to analysed groups
getTargetsColours <- function(targets) {

    ##### Predefined selection of colours for groups
    targets.colours <- c("red","blue","green","darkgoldenrod","darkred","deepskyblue", "coral", "cornflowerblue", "chartreuse4", "bisque4", "chocolate3", "cadetblue3", "darkslategrey", "lightgoldenrod4", "mediumpurple4", "orangered3","indianred1","blueviolet","darkolivegreen4","darkgoldenrod4","firebrick3","deepskyblue4", "coral3", "dodgerblue1", "chartreuse3", "bisque3", "chocolate4", "cadetblue", "darkslategray4", "lightgoldenrod3", "mediumpurple3", "orangered1")

    f.targets <- factor(targets)
    vec.targets <- targets.colours[1:length(levels(f.targets))]
    targets.colour <- rep(0,length(f.targets))
    for(i in 1:length(f.targets))
    targets.colour[i] <- vec.targets[ f.targets[i]==levels(f.targets)]

    return( list(vec.targets, targets.colour) )
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
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
              help="Variable from the samples annotation file to be used for samples colouring"),
  make_option(c("-p", "--principal_component"), action="store", default=NA, type='character',
              help="The principal component to be plotted together with the two subsequent most prevalent principal components"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
annFile <- opt$target
target <- opt$colouring
PC1 <- as.numeric(opt$principal_component)
PC2 <- PC1 + 1
PC3 <- PC1 + 2
outFolder <- opt$dir


#===============================================================================
#    Main
#===============================================================================

# splitting exp_file string to retrieve all the identified samples
exp_files = unlist(strsplit(expFile, ","))

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)

for (j in 1:length(exp_files)) {
  
  ef = paste(outFolder,"norm_files",exp_files[j],sep = "/")

  ##### Read file with expression data
  expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

  ##### Deal with the duplicated genes
  rownames(expData) = make.names(expData$Gene, unique=TRUE)
  expData <- expData[,-1]

  selected_samples <- intersect(as.character(annData$File_name),colnames(expData))
  expData.subset <- as.data.frame(data.matrix(expData[,colnames(expData) %in% selected_samples]))

  ##### Make sure that the samples in the expression matrix and annotaiton file are in the same order
  expData.subset <- expData.subset[, selected_samples]
  
  ##### Remove genes with NAs (mainly after Z-score transormation of genes with 0 values across all samples)
  expData.subset <- na.omit(expData.subset)

  #===============================================================================
  #     Principal components analysis
  #===============================================================================

  ##### Keep only probes with variance > 0 across all samples
  rsd <- apply(expData.subset,1,sd)
  expData <- expData.subset[rsd>0,]

  ##### Assign colours according to defined sample annotation
  targets <- subset(annData, File_name %in% colnames(expData))[,target]
  targets.colour <- getTargetsColours(targets)

  ##### Perform principal components analysis
  expData_pca <- prcomp(t(expData), scale=FALSE)

  ##### Get variance importance for all principal components
  importance_pca <- summary(expData_pca)$importance[2,]
  importance_pca <- paste(round(100*importance_pca, 2), "%", sep="")

  ##### Generate bar-plot (PLOTLY)
  ##### Prepare data frame
  expData_pca.df <- data.frame(paste0("PC ", c(1:length(importance_pca))), as.numeric(gsub("%", "",importance_pca)))
  
  colnames(expData_pca.df) <- c("PC", "Variances")
  ##### The default order will be alphabetized unless specified as below
  expData_pca.df$PC <- factor(expData_pca.df$PC, levels = expData_pca.df[["PC"]])
  
  p <- plot_ly(expData_pca.df, x = ~PC, y = ~Variances, type = 'bar', width = 800, height = 600) %>%
  layout(title = "The variances captured by principal components", xaxis = list(title = ""), margin = list(l=50, r=50, b=100, t=100, pad=4), autosize = F)
  
  ##### Save the box-plot as html (PLOTLY)
  widget_fn = paste(outFolder,paste0("pca_bp","_",j,".html"),sep="/")
  htmlwidgets::saveWidget(p, file=widget_fn, selfcontained = FALSE)

  ##### Generate PCA plot (PLOTLY)
  ##### Prepare legend coordinates
 if ( length(unique(targets)) > 6 ) {

    leg.orientation <- "v"
    leg.y <- 0.9
 } else {
    leg.orientation <- "h"
    leg.y <- 1.1
 }

  ##### Prepare data frame
  expData_pca.df <- data.frame(targets, expData_pca$x[,PC1], expData_pca$x[,PC2], expData_pca$x[,PC3])
  colnames(expData_pca.df) <- c("Target", "PC1", "PC2", "PC3")
  rownames(expData_pca.df) <- subset(annData, File_name %in% colnames(expData))[,"File_name"]

  p <- plot_ly(expData_pca.df, x = ~PC1, y = ~PC2, color = ~Target, text=rownames(expData_pca.df), colors = targets.colour[[1]], type='scatter', mode = "markers", marker = list(size=10, symbol="circle"), width = 800, height = 600) %>%
  layout(title = "", xaxis = list(title = paste("PC ", PC1, " (",importance_pca[PC1],")",sep="")), yaxis = list(title = paste("PC ", PC2, " (",importance_pca[PC2],")",sep="")), margin = list(l=50, r=50, b=50, t=20, pad=4), autosize = F, showlegend = TRUE, legend = list(orientation = leg.orientation, y = leg.y))

  widget_fn = paste(outFolder,paste0("pca_2d","_",j,".html"),sep="/")
  ##### Save the box-plot as html (PLOTLY)
  htmlwidgets::saveWidget(p, file=widget_fn, selfcontained = FALSE)

  ##### Generate PCA 3-D plot (PLOTLY)
  p <- plot_ly(expData_pca.df, x = ~PC1, y = ~PC2, z = ~PC3, color = ~Target, text=rownames(expData_pca.df), colors = targets.colour[[1]], type='scatter3d', mode = "markers", marker = list(size=8, symbol="circle"), width = 800, height = 800) %>%
  layout(scene = list(xaxis = list(title = paste("PC ", PC1, " (",importance_pca[PC1],")",sep="")), yaxis = list(title = paste("PC ", PC2, " (",importance_pca[PC2],")",sep="")), zaxis = list(title = paste("PC ", PC3, " (",importance_pca[PC3],")",sep="")) ), margin = list(l=50, r=50, b=50, t=10, pad=4), autosize = F, showlegend = TRUE, legend = list(orientation = leg.orientation, y = leg.y))
  
  ##### Save the box-plot as html (PLOTLY)
  widget_fn = paste(outFolder,paste0("pca_3d","_",j,".html"),sep="/")
  htmlwidgets::saveWidget(p, file=widget_fn, selfcontained = FALSE)

  ##### Close any open graphics devices
  graphics.off()
}
