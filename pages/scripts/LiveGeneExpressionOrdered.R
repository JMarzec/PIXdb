################################################################################
#
#   File name: LiveGeneExpressionOrdered.R
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
#   Description: Script generating box-plots and bar-plots to visualise expression measurments across samples and groups (as indicated in target file) from normalised expression data for user-defined gene. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript LiveGeneExpressionOrdered.R --exp_file /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/platforms/Affy_U133Plus2/norm_files/Affy_U133Plus2_1.processed.genename.csv --target /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/platforms/Affy_U133Plus2/target.txt --colouring Target --order Normal,HGPIN,Tumour,Tumour_met,Metastasis --gene PTEN --dir /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/tmp --hexcode dasdas
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Third arg:      Variable from the samples annotation file to be used for samples grouping
#   Forth arg:      ID of gene/probe of interest
#   Fifth arg:      Full path with name of the output folder

#
################################################################################

# silent warnings
options(warn=-1)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

#===============================================================================
#    Functions
#===============================================================================

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0


##### Assign colours to analysed groups (for plots filling)
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
  make_option(c("-o", "--order"), action="store", default=NA, type='character',
              help="Groups ordering on the plots"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of gene/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
annFile <- opt$target
target <- opt$colouring
order <- opt$order
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

gene = make.names(gene)

# splitting exp_file string to retrieve all the identified samples
exp_files = unlist(strsplit(expFile, ","))

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)

for (j in 1:length(exp_files)) {

  #ef = paste(outFolder,"norm_files",exp_files[j],sep = "/")
  ef = exp_files[j]

  ##### Read file with expression data
  expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

  ##### Deal with the duplicated genes
  if( nrow(expData) != 0 ) {
    rownames(expData) = make.names(expData$Gene.name, unique=TRUE)
    expData <- expData[,-1]

    selected_samples <- intersect(as.character(annData$File_name),colnames(expData))
    expData.subset <- as.data.frame(t(scale(t(data.matrix(expData[,colnames(expData) %in% selected_samples])))))

    if ( gene %in% rownames(expData.subset) ) {
        if (j == 1) {
            gene.expr <- expData.subset[gene, ]
        } else {
            gene.expr <- cbind(gene.expr, expData.subset[gene, ])
        }
    }

  ##### Remove samples from platfrom for which the data cannot be processed
  } else {
      annData <- annData[ annData$File_name %!in% colnames(expData),  ]
  }
}

##### Make sure that the annotation contains info only about samples in the data matrix
annData <- annData[ annData$File_name %in% colnames(gene.expr),  ]

##### Make sure that the samples order is the same in the annotation file and in the data matrix
gene.expr <- gene.expr[ annData$File_name ]

##### Change working directory to the project workspace
setwd(outFolder)

#===============================================================================
#     Generate box-plot and bar-plot
#===============================================================================

targets <- annData[,target]
targets.colour <- getTargetsColours(targets)


##### Order samples accordingly to investigated groups
dataByGroups <- NULL
targetByGroups <- NULL
colourByGroups <- NULL
expr <- list()
averegeExpr <- NULL

for (i in 1:length(unique(targets))) {

    ##### Separate samples accordingly to investigated groups
    expr.tmp <- gene.expr[ targets %in% unique(sort(targets))[i] ]
    averegeExpr <- c(averegeExpr, rep(mean(as.numeric(expr.tmp)), length(expr.tmp)))
    colour <- targets.colour[[2]][ targets %in% unique(sort(targets))[i] ]

    ##### Order samples within each group based on the expression level
    expr.tmp <- expr.tmp[order(expr.tmp)]
    colour <- colour[order(expr.tmp)]

    expr[[i]] <- as.numeric(expr.tmp)
    names(expr)[[i]] <- unique(sort(targets))[i]
    dataByGroups <- c(dataByGroups, expr.tmp)
    targetByGroups <- c(targetByGroups, targets[ targets %in% unique(sort(targets))[i] ])
    colourByGroups <- c(colourByGroups, colour)
}

dataByGroups <- unlist(dataByGroups)

##### Generate box-plot  (PLOTLY)
##### Prepare data frame
gene.expr.df <- data.frame(targets, as.numeric(gene.expr))
colnames(gene.expr.df) <- c("Group", "Expression")

##### Apply defined group order
order = unlist(strsplit(order, ","))
order <- order[order %in% gene.expr.df$Group]
gene.expr.df$Group <- factor(gene.expr.df$Group, levels=order)


p <- plot_ly(gene.expr.df, y= ~Expression, color = ~Group, type = 'box', jitter = 0.3, pointpos = 0, boxpoints = 'all', colors = targets.colour[[1]], width = 800, height = 600) %>%
layout(yaxis = list( title = paste0(gene, "  mRNA expression (z-score)")), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5), showlegend=TRUE)

##### Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode,"_box.html"), selfcontained = FALSE)


##### Generate bar-plot (PLOTLY)
##### Prepare data frame
dataByGroups.df <- data.frame(targetByGroups, names(dataByGroups), as.numeric(dataByGroups))
colnames(dataByGroups.df) <- c("Group","Sample", "Expression")

##### Apply defined group order
dataByGroups.df$Group <- factor(dataByGroups.df$Group, levels=order)
dataByGroups.df <- dataByGroups.df[ order(dataByGroups.df$Group), ]

##### The default order will be alphabetized unless specified as below
dataByGroups.df$Sample <- factor(dataByGroups.df$Sample, levels = dataByGroups.df[["Sample"]])

p <- plot_ly(dataByGroups.df, x = ~Sample, y = ~Expression, color = ~Group, type = 'bar', colors = targets.colour[[1]], width = 800, height = 400) %>%
layout(title = "", xaxis = list( tickfont = list(size = 10), title = ""), yaxis = list(title = paste0(gene, "  mRNA expression (z-score)")), margin = list(l=50, r=50, b=150, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5), showlegend=TRUE)

##### Save the bar-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode,"_bar.html"), selfcontained = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
