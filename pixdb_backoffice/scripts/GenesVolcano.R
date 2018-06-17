################################################################################
#
#   File name: GenesVolcano.R
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
#   Description: Script performing clustering and generating heatmap for user-defined genes. The script imputes missing data for genes with non-missing data in >50% of samples. Genes with >50% missing data are removed prior clustering. Missing values should be denoted as 'NA'. The heatmap presents only the 200 genes with the highest expression variance across samples. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: R --file=./GenesVolcano.R --args "/Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/crossplatform/Meta_genes_TumourvsNormal_HGPINvsNormal_TumourvsHGPIN_Tumour_metvsTumour_MetastasisvsTumour_DEbound_summary.txt" "0.000000001" "1" "/Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/crossplatform"
#
#   First arg:      Full path with name of the integrative analysis results summary file
#   Second arg:     Threshold to indicate significant the P values on the plot
#   Third arg:      Log2 fold-change threshold to highlight genes on the plot
#   Fourth arg:     Full path with name of the output folder
#
################################################################################

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

library(gplots)
library(plotly)

#===============================================================================
#    Main
#===============================================================================

##### Catch the arguments from command line
args <- commandArgs()

resultsFile <- args[4]
p.threshold <- as.numeric(args[5])
fc.threshold <- as.numeric(args[6])
outFolder <- args[7]

##### Check if all required parameters were provided
if ( is.na(args[4]) || is.na(args[5]) || is.na(args[6]) || is.na(args[7]) ) {

    cat("\nError: Some arguments are missing! Please provide all required parameters.\n\n")
    q()
}

##### Read file with expression data
resultsData <- read.table(resultsFile,sep="\t", as.is=TRUE, header=TRUE, row.names=NULL)

##### Generate stats tables for each biological comparison
comps.stats <- list("TvsN"=NULL, "HvsN"=NULL, "TvsH"=NULL, "TmvsT"=NULL, "MvsT"=NULL)

for (i in 1:length(names(comps.stats)) ) {

	comp <- grepl(names(comps.stats)[i], colnames(resultsData), perl=TRUE)
	comp.resultsData <- data.frame(resultsData[, comp])

	##### Change missing values to NA. NOTE: this will throw warnings
	comp.resultsData[] <- lapply(comp.resultsData, function(x) as.numeric(as.character(x)))
	comps.stats[[names(comps.stats)[i]]] <- cbind(data.frame( paste(resultsData[, 2], resultsData[, 1], sep=" : ") ), comp.resultsData)
	names(comps.stats[[names(comps.stats)[i]]])[1] <- "gene"
}


#===============================================================================
#     Differenatial expression analysis results visualisation
#===============================================================================

#####  P-value histograms
for (i in 1:length(names(comps.stats)) ) {

    pdf(file = paste0(outFolder,"/", names(comps.stats)[i], "_P_hist.pdf"))
	P.values <- comps.stats[[names(comps.stats)[i]]][5]
    histogram <- hist(P.values[!is.na(P.values)], breaks=seq(0,1,by= 0.01), main=names(comps.stats)[i], xlab="p-value")
    exprected_p.value <- mean(histogram$counts)+(sd(histogram$counts)*1)
    abline(v=p.threshold,col="red")
    abline(h=exprected_p.value,col="blue")
    dev.off()
}

##### Generate histogram (PLOTLY)
for (i in 1:length(names(comps.stats)) ) {

	##### Get the P values
	P.values <- comps.stats[[names(comps.stats)[i]]][5]
	p <- plot_ly(x = ~P.values[!is.na(P.values)], type = "histogram", nbinsx = 500) %>%
	layout(xaxis = list( title = "Combined P value"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = TRUE, width = 800, margin = list(l=150, r=50, b=150, t=50, pad=4), showlegend = FALSE)

	##### Save the heatmap as html (PLOTLY)
	htmlwidgets::saveWidget(as_widget(p), paste0(outFolder,"/", names(comps.stats)[i], "_P_hist.html"), selfcontained = FALSE)
}


#####  Volcano plots of log2 fold-changes versus significance
for (i in 1:length(names(comps.stats)) ) {

	##### Get the P and log2 fold-change values
    P.values <- comps.stats[[names(comps.stats)[i]]][5]
	P.values <- P.values[!is.na(P.values)]
	log2fc <- comps.stats[[names(comps.stats)[i]]][4]
	log2fc <- log2fc[!is.na(log2fc)]

    pdf(file = paste0(outFolder,"/", names(comps.stats)[i], "_volcano", ".pdf"))
    plot(log2fc,-log10(P.values),pch=16,cex=0.5,xlab="Log2 fold-change",ylab="-log10(combined P value)",main=names(comps.stats)[i],col="grey")
    #####  Highlight genes with logFC above specified threshold
    points(log2fc[abs(log2fc)>fc.threshold],-log10(P.values[abs(log2fc)>fc.threshold]),cex=0.5,pch=16)
    abline(h=-log10(p.threshold),col="red", lty = 2)
    dev.off()
}


##### Generate volcano plot (PLOTLY)
for (i in 1:length(names(comps.stats)) ) {

	##### Get gene names, the P and log2 fold-change values
	genes <- comps.stats[[names(comps.stats)[i]]][1]
	log2fc <- comps.stats[[names(comps.stats)[i]]][4]
    P.values <- -log10(comps.stats[[names(comps.stats)[i]]][5])

	##### Combine gene names, the P and log2 fold-change values and remove gene with missing data
	log2fc.P.df <- data.frame(cbind(genes, log2fc, P.values))
	log2fc.P.df <- log2fc.P.df[!is.na(log2fc), ]

	##### Add info about genes that meet the log2 fold-change and various p-value thresholds
	log2fc.P.df <- cbind(log2fc.P.df, rep(0,nrow(log2fc.P.df)))
	colnames(log2fc.P.df) <- c("gene", "log2fc", "P.values", "signif.status")

	##log2fc.P.df$signif.status[ abs(log2fc.P.df$log2fc) > fc.threshold & log2fc.P.df$P.values > -log10(p.threshold) ] <- 1
	log2fc.P.df$signif.status <- round(log2fc.P.df$log2fc,digit=0)


	p <- plot_ly(log2fc.P.df, x = ~log2fc, y = ~P.values, text= ~gene, type='scatter', color = ~factor(signif.status), colors = c("blue","grey", "red"), mode = "markers", marker = list(size=6, symbol="circle"), width = 800, height = 600) %>%
	layout(title = "", xaxis = list(title = "Log2 fold-change"), yaxis = list(title = "-log10(combined P value)"), margin = list(l=50, r=50, b=50, t=20, pad=4), autosize = F, showlegend = TRUE)

	##### Save the heatmap as html (PLOTLY)
	htmlwidgets::saveWidget(as_widget(p), paste0(outFolder,"/", names(comps.stats)[i], "_volcano.html"), selfcontained = FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
