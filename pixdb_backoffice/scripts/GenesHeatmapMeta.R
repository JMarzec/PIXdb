################################################################################
#
#   File name: GenesHeatmapMeta.R
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
#   Description: Script performing clustering and generating heatmap for meta-analysis results. If the gene list is provided, their order will be retained in the heatnmap. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: R --file=./GenesHeatmapMeta.R --args "/Library/WebServer/Documents/PIXdb/pixdb_backoffice/data/crossplatform/Meta_genes_TumourvsNormal_HGPINvsNormal_TumourvsHGPIN_Tumour_metvsTumour_MetastasisvsTumour_DEbound_summary.txt" "/Library/WebServer/Documents/PIXdb/pixdb_backoffice/data/crossplatform/Meta_gene_list_exp.txt"
#
#   First arg:      Full path with name of the meta-analysis results file
#   Second arg (OPTIONAL):   Full path with name of the text file listing genes to be considered for the heatmap. Individual genes are expected to be listed per row
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

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0


##### Assign colours to analysed groups
getTargetsColours <- function(targets) {

    ##### Predefined selection of colours for groups
    targets.colours <- c("red","blue","green","darkgoldenrod","darkred","deepskyblue", "coral", "cornflowerblue", "chartreuse4", "bisque4", "chocolate3", "cadetblue3", "darkslategrey", "lightgoldenrod4", "mediumpurple4", "orangered3")

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

library(gplots)
library(plotly)
library(heatmaply)

#===============================================================================
#    Main
#===============================================================================

##### Catch the arguments from command line
args <- commandArgs()

expFile <- args[4]

##### Check if all required parameters were provided
if ( is.na(args[4]) ) {

    cat("\nError: Some arguments are missing! Please provide all required parameters.\n\n")
    q()
}

##### Read file with expression data
expData <- read.table(expFile,sep="\t", as.is=TRUE, header=TRUE, row.names=1)

##### Retieve the expression data file name
coreName <- strsplit(expFile, "/")
outFolder <- paste(unlist(coreName)[-length(unlist(coreName))], collapse = "/")
coreName <- coreName[[1]][length(coreName[[1]])]


##### If provided, get the list of genes of interest
if ( !is.na(args[5]) ) {

    genesFile <- args[5]

    ##### Read file with the gene list
    genes <- unlist(read.table(genesFile,sep="\t",as.is=TRUE,header=FALSE))

} else {
    genes <- rownames(expData)
}

##### Keep only user-defined genes. In this case these are only the top-500 meta-analysis genes
expData <- expData[ expData$hgnc_symbol %in% genes, ]
rownames(expData) <- expData$hgnc_symbol

##### Keep only the gene ranks info
rownames(expData) <- expData$hgnc_symbol
expData.rank <- expData[ , grepl("rank.*percentile", colnames(expData), perl=TRUE) ]

##### Retain the original genes order
expData.rank <- expData.rank[ genes, ]

##### Change null valuse (where no data were available for corresponding comparison) to NAs
expData.rank[ expData.rank == "null" ] <- NA

expData.rank = as.matrix(as.data.frame(lapply(expData.rank, as.numeric)))

colnames(expData.rank) <- c("(1) Primary tumour vs Benign", "(2) HGPIN vs Benign", "(3) Primary tumour vs HGPIN", "(4) Metastatic primary tumour vs Primary tumour", "(5) Metastasis vs Primary tumour")
rownames(expData.rank) <- genes


##### Identify genes of interest not present in the expression matrix
absentGenes <- genes[genes %!in% rownames(expData.rank)]

##### Change working directory to the project workspace
setwd(outFolder)

##### Report genes of interest not present in the expression matrix
if ( length(absentGenes) > 0 ) {

    write(absentGenes, file = "Meta_absent_genes.txt", append = FALSE, sep="\t")
}

##### Report used parameters to a file
write(args, file = "heatmap_exp_parameters.txt", append = FALSE, sep="\t")


#===============================================================================
#     Rank heat map
#===============================================================================

##### Prepare colours for sample groups
targets.colour <- getTargetsColours(colnames(expData.rank))

##### Generate heatmap (PLOTLY)
p <- heatmaply(expData.rank, Rowv=NULL, Colv=NULL, scale="none", trace="none", hide_colorbar = FALSE, fontsize_row = 8, fontsize_col = 8, label_names=c("Gene","Comparison","Rank (%)"), key.title = "Rank (%)") %>%
layout(autosize = TRUE, width = 650, height = 660, margin = list(l=150, r=50, b=210, t=22, pad=4), showlegend = TRUE)

##### Save the heatmap as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), "Meta_heatmap_rank.html", selfcontained = FALSE)


#===============================================================================
#     Fold-change heat map
#===============================================================================

##### Keep only the gene fold-change info
expData.fc <- expData[ , grepl("log2fc", colnames(expData), perl=TRUE) ]

##### Retain the original genes order
expData.fc <- expData.fc[ genes, ]

##### Change null valuse (where no data were available for corresponding comparison) to NAs
expData.fc[ expData.fc == "null" ] <- NA

expData.fc = as.matrix(as.data.frame(lapply(expData.fc, as.numeric)))

colnames(expData.fc) <- c("(1) Primary tumour vs Benign", "(2) HGPIN vs Benign", "(3) Primary tumour vs HGPIN", "(4) Metastatic primary tumour vs Primary tumour", "(5) Metastasis vs Primary tumour")
rownames(expData.fc) <- genes

##### Generate heatmap (PLOTLY)
p <- heatmaply(expData.fc, Rowv=NULL, Colv=NULL, scale="none", colors = colorRampPalette(c("darkblue","darkblue","darkblue","darkblue","white","darkred","darkred","darkred","darkred"))(100), trace="none", hide_colorbar = FALSE, fontsize_row = 8, fontsize_col = 8, label_names=c("Gene","Comparison","log2FC"), key.title = "log2FC") %>%
layout(autosize = TRUE, width = 650, height = 660, margin = list(l=150, r=50, b=210, t=22, pad=4), showlegend = TRUE)

##### Save the heatmap as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), "Meta_heatmap_fc.html", selfcontained = FALSE)


#===============================================================================
#     Rnak * fold-change heat map
#===============================================================================

##### Change the positive and negative fold-changes to 1 and -1, respectively, to be used to multioly with rank values
expData.fc.dir <- expData.fc
expData.fc.dir[ expData.fc.dir < 0 ] <- -1
expData.fc.dir[ expData.fc.dir >= 0 ] <- 1

expData.fc.rank = expData.fc.dir * expData.rank

expData.fc.rank[ is.na(expData.fc.rank) ] <- 100

##### Transpose matrix
expData.t <- data.frame(t(expData.fc.rank ))

##### Cluster genes
hc <- hclust(as.dist(1-cor(expData.t , method="pearson")), method="ward.D")


##### Generate heatmap (PLOTLY)
p <- heatmaply(expData.fc.rank, Rowv=NULL, Colv=NULL, scale="none", colors = colorRampPalette(c("white","white","grey","darkgrey","darkblue","darkred","darkgrey","grey","white","white"))(1000), trace="none", hide_colorbar = FALSE, fontsize_row = 8, fontsize_col = 8, label_names=c("Gene","Comparison","Rank (%)"), key.title = "Rank (%)") %>%
layout(autosize = TRUE, width = 650, height = 660, margin = list(l=150, r=50, b=210, t=22, pad=4), showlegend = TRUE)

##### Save the heatmap as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), "Meta_heatmap_rank_fc.html", selfcontained = FALSE)


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
