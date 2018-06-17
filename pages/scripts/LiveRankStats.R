################################################################################
#
#   File name: LiveRankStats.R
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
#   Command line use example: Rscript LiveRankStats.R --results_file /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/crossplatform/Meta_genes_TumourvsNormal_HGPINvsNormal_TumourvsHGPIN_Tumour_metvsTumour_MetastasisvsTumour_DEbound_summary.txt --gene MKI67 --dir /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/tmp --hexcode dmasmd
#
#   First arg:      Full path with name of the integrative analysis results summary file
#   Second arg:     ID of gene/probe of interest
#   Third arg:      Full path with name of the output folder
#   Fourth arg:     Unique id to save temporary plots
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

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(plotly))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--results_file"), action="store", default=NA, type='character',
              help="File containing gene ranks and stats"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of gene/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

resultsFile <- opt$results_file
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

gene = make.names(gene)

##### Read file with gene ranks and stats
resultsData <- read.table(resultsFile,sep="\t", as.is=TRUE, header=TRUE, row.names=NULL)

##### Get info for the gene of interest
geneData <- resultsData[ resultsData$hgnc_symbol==gene, ]

##### Extract gene rank (percentile), combined P value and log2 FC info
geneData.rank <- unlist(geneData[ , grepl( "percentile", colnames(geneData), perl=TRUE)])
geneData.log2fc <- unlist(geneData[ , grepl( "log2fc", colnames(geneData), perl=TRUE)])
geneData.combined_p.log <- round(-log10(as.numeric(unlist(geneData[ , grepl( "combined_p", colnames(geneData), perl=TRUE)]))), digits=2)
geneData.combined_p <- unlist(geneData[ , grepl( "combined_p", colnames(geneData), perl=TRUE)])

geneData.df <- data.frame(factor(c(1:5), levels=c(1:5)), c(rep(0,5)), c("(1) Primary tumour vs Benign", "(2) HGPIN vs Benign", "(3) Primary tumour vs HGPIN", "(4) Metastatic primary tumour vs Primary tumour", "(5) Metastasis vs Primary tumour"), geneData.rank, geneData.log2fc, geneData.combined_p.log)

colnames(geneData.df) <- c("order", "base", "comparison", "rank", "log2FC", "combined_P")

##### The default order will be alphabetized unless specified as below:
geneData.df$comparison <- factor(geneData.df$comparison, levels = geneData.df[["comparison"]])


##### Generate bar plot with bars' colours corresponding to the biological comparisons
#p <- plot_ly(geneData.df, x = ~comparison, y = ~base,  type = 'bar', orientation = 'horizontal', name = "Baseline",  width = 800, height = 600)  %>%
#add_trace( y = ~log2FC, marker = list( color = c("goldenrod","tan","chocolate","sienna","maroon"), line = list(color = 'rgba(0, 0, 0, 0.4)', width = 1)), color = ~factor(comparison), name = ~comparison )  %>%


##### Generate bar plot with bars' colours reflecting the combined P-values in each biological comparison
p <- plot_ly(geneData.df, x = ~comparison, y = ~base,  type = 'bar', orientation = 'horizontal',  width = 800, height = 600)  %>%
add_trace( y = ~log2FC, marker = list( size=geneData.rank, color=geneData.rank, colorbar=list(title='Rank (%)'), colorscale='Viridis', cauto=F, cmin=0, cmax=100, reversescale = FALSE, line = list(color = 'rgba(0, 0, 0, 0.4)', width = 1)), name = "log2 FC", text = paste0("P = ", geneData.combined_p), textposition = 'outside' )  %>%


layout(
  title = "",
  xaxis = list(title = ""),
  yaxis = list(title = paste0(gene, " log2 fold-change")),
  margin = list(l=70, r=50, b=200, t=50, pad=4),
  autosize = F,
  barmode = 'stack',
  showlegend=FALSE
)

##### Change working directory to the project workspace
setwd(outFolder)

##### Save the bar-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode,"_bar.html"), selfcontained = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
