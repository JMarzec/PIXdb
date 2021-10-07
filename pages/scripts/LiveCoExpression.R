################################################################################
#
#   File name: GeneCoExprMultiGenes.R
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
#   Description: Script for calculating coexpression between user-defined genes/probes. Person correlation coefficient is used to measure correaltion between genes' expression. The pairwise correlation between expression of user-defined genes is depicted in a form of a correlation matrix heat map. NOTE: the script allowes to process gene matrix with duplicated gene IDs. It allows to process up to 50 genes
#
#   Command line use example: R --file=./GeneCoExprMultiGenes.R --args "TCGA_PAAD_normalized.txt" "TCGA_PAAD_target.txt" "Genes_of_interest.txt" "Example_results/PC_GeneCoExprMultiGenes" "PDAC"
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Third arg:      ID of gene/probe of interest
#   Fourth arg:     Full path with name of the output folder
#   Fifth arg (OPTIONAL):  Samples group to use for the analysis
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

##### Prepare object to write into a file
prepare2write <- function (x) {

	x2write <- cbind(rownames(x), x)
    colnames(x2write) <- c("",colnames(x))
	return(x2write)
}

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(gplots))
suppressMessages(library(plotly))
suppressMessages(library(heatmaply))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-p", "--genes"), action="store", default=NA, type='character',
              help="ID of genes/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
annFile <- opt$target
gene_list <- opt$genes
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

# splitting exp_file string to retrieve all the identified samples
exp_files = unlist(strsplit(expFile, ","))

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)

##### Read gene list
genes = unlist(strsplit(gene_list, ","))
genes = make.names(genes, unique=TRUE)

for (j in 1:length(exp_files)) {

    #ef = paste(outFolder,"norm_files",exp_files[j],sep = "/")
    ef = exp_files[j]

    ##### Read file with expression data
    expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

    ##### Deal with the duplicated genes
    rownames(expData) = make.names(expData$Gene.name, unique=TRUE)
    expData <- expData[,-1]

    selected_samples <- intersect(as.character(annData$File_name),colnames(expData))
    expData.subset <- as.data.frame(t(scale(t(data.matrix(expData[,colnames(expData) %in% selected_samples])))))

	##### Identify genes of interest not present in the expression matrix
	absentGenes <- genes[genes %!in% rownames(expData)]

	##### Check if used-defined genes are present in the data
	gene.expr <- expData.subset[rownames(expData) %in% genes, ]
	genes <- rownames(gene.expr)

	##### Change working directory to the project workspace
	setwd(outFolder)

	#===============================================================================
	#     Calculate Pearson correlation coefficients
	#===============================================================================

	##### Remove gense with standard deviation = 0 (otherwise the cor.test complains)
	#####  Keep only genes/probes with variance > 0 across all samples (otherwise the cor.test complains)
	rsd<-apply(gene.expr,1,sd)
	expData.subset <- gene.expr[rsd>0.5,]

	##### Calculate Pearson correlation coefficient for user-defined genes
	corr.res <- matrix(data = 0, nrow = nrow(expData.subset), ncol = (2*length(genes))+1, dimnames = list( rownames(expData.subset), c( "Gene", paste(rep(genes, each = 2), c("Correlation", "P-value")) ) ))

	for ( i in 1:length(genes) ) {
		for ( x in 1:nrow(expData.subset) ) {

	    #### Pearson correlation coefficient and test P
			corr.res[x, paste0(genes[i], " Correlation")] <- cor.test( as.numeric(expData.subset[ genes[i] ,]), as.numeric(expData.subset[ x, ]), method = "pearson" )$estimate;
			corr.res[x, paste0(genes[i], " P-value")] <- cor.test( as.numeric(expData.subset[ genes[i] ,]), as.numeric(expData.subset[ x, ]), method = "pearson" )$p.value;
		}
	}

	corr.res <- data.frame(corr.res)
	corr.res[,"Gene"] <- rownames(expData.subset)
	colnames(corr.res) <- c( "Gene", paste(rep(genes, each = 2), c("Correlation", "P-value")) )

	##### Write the results into a file
	write.table(corr.res, file=paste0(hexcode,"_corr.txt"), row.names=FALSE,  quote=FALSE)

	#===============================================================================
	#     Pairwise correlation heat map for defined genes
	#===============================================================================

	##### Extract the the correlation results for the user-defined genes
	corr.res.genes <- corr.res[genes, paste(genes, "Correlation")]
	colnames(corr.res.genes) <- rownames(corr.res.genes)
	corr.res.genes[upper.tri(corr.res.genes)] <- NA


	##### Generate heatmap including the top correlated genes (PLOTLY)
	p <- heatmaply(data.frame(corr.res.genes), labCol= rownames(corr.res.genes), labRow= colnames(corr.res.genes), dendrogram="none", colors = colorRampPalette(c("darkblue","darkslateblue","darkslateblue","white","firebrick3","firebrick3","firebrick4"))(100), scale="none", trace="none", limits = c(-1,1), hide_colorbar = FALSE, fontsize_row = 8, fontsize_col = 8) %>%
	layout(autosize = TRUE, width = 800, margin = list(l=150, r=50, b=150, t=50, pad=4), showlegend = FALSE)

	##### Save the heatmap as html (PLOTLY)
	htmlwidgets::saveWidget(as_widget(p), paste0(hexcode,"_corr_heatmap.html"), selfcontained = FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
