### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0           	07/02/2012     Emanuela        			init
# 1.1           	Dec/2013      	Ros              				for BCCTB data portal
# 1.2				18/06/2015		Emanuela					tidying script, increased annotation, removal of a dataset-specific section, removing redundancies
# 1.3				xx/08/2015		Emanuela					adaptation to avoid calling FC library and improvement of KM plots
# 1.4       21/06/2017    Stefano           adapt to be included in the new BoB portal
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

# DICHOTOMISE EXPRESSION DATA BASED ON MEDIAN
local.dichotomise.dataset <- function(x, split_at = 99999) {
  if (split_at == 99999) { split_at = median(x, na.rm = TRUE); }
  return( as.numeric( x > split_at ) );
}


#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(survival))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of genes/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
annFile <- opt$target
gene <- opt$gene
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

##### Selecting samples where the survival statistics are available
annData <- annData[ complete.cases(annData[ , "surv.stat" ]) , ];

setwd(outFolder);

for (j in 1:length(exp_files)) {

  ef = exp_files[j]

  ##### Read file with expression data
  expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

  ##### Deal with the duplicated genes
  rownames(expData) = make.names(expData$Gene.name, unique=TRUE)
  expData <- expData[,-1]

  #### Filtering expression data ###
  selected_samples <- intersect(as.character(annData$File_name),colnames(expData))
  expData.subset <- as.data.frame(t(scale(t(data.matrix(expData[,colnames(expData) %in% selected_samples])))))
  #exp.data.slimmed <- expData.subset[ , ann.data.slimmed$File_name ];
  exp.data.slimmed <- expData.subset

  ##### Make sure that the annotation contains info only about samples in the data matrix
  ann.data.slimmed <- annData[ annData$File_name %in% colnames(expData.subset),  ]

  # extract surv data
  surv.stat <- as.numeric( ann.data.slimmed[ , "surv.stat"]);
  # extract surv time
  surv.time <- as.numeric( ann.data.slimmed[ , "surv.time"]);
  # extract surv type
  surv.type <- as.character( ann.data.slimmed[ , "surv.type"])[1];


  # gene = specified by user
  rg <- local.dichotomise.dataset( as.matrix(exp.data.slimmed[ gene , ] ));
  cox.fit <- summary( coxph( Surv(surv.time, surv.stat) ~ rg) );
  cox.km <- survfit(coxph(Surv(surv.time, surv.stat) ~ strata(rg)));

  if ( cox.fit$sctest[3] < 0.001 ) {

      pValue <- "Log-rank P < 0.001"
  } else {
      pValue <- paste("Log-rank P = ", round(cox.fit$sctest[3], digits = 3), sep="")
  }


  ##### Prepare a table below the plot showing numbers at risk and number of events at different times
  times <- seq(0, max(cox.km$time), by = max(cox.km$time)/5)
  risk.data <- data.frame(strata = summary(cox.km, times = times, extend = TRUE)$strata, time = summary(cox.km, times = times, extend = TRUE)$time, n.risk = summary(cox.km, times = times, extend = TRUE)$n.risk)

  risk.dataLow <- t(risk.data[1:(nrow(risk.data)/2), ])
  risk.dataHigh <- t(risk.data[(nrow(risk.data)/2+1):nrow(risk.data), ])


  png(filename=paste0(hexcode,"_KMplot.png"), width = 680, height = 680, units = "px", pointsize = 18)
  plot(cox.km, mark.time=TRUE, col=c("darkblue", "red"), xlab="Survival time", ylab="Survival probability", lty=c(1,1), lwd=2.5, ylim=c(-0.1,1.13), xlim=c(0-((max(cox.km$time)-min(cox.km$time))/10),max(cox.km$time)+((max(cox.km$time)-min(cox.km$time))/10)), xaxt="none")
  axis(1, at=round(seq(0, max(cox.km$time), by = max(cox.km$time)/5), digits=1))

  ##### Report HR value (with 95% confidence intervals) and p-values
  legend("topright", legend=c(paste("HR=", round(cox.fit$conf.int[1,1], digits=2), sep=""), paste("95% CI (", round(cox.fit$conf.int[1,3], digits=2), "-", round(cox.fit$conf.int[1,4], digits=2), ")", sep=""), pValue), box.col="transparent", bg="transparent")

  ##### Report number at risk
  legend("topleft", legend=c("Low expression", "High expression"), col=c("darkblue", "red"), lty=c(1,1), lwd=2.5, box.col="transparent", bg="transparent")
  legend("bottom", legend="Number at risk\n\n\n\n", box.col="transparent", bg="transparent")
  text( risk.dataLow[2,], rep(-0.05, length(risk.dataLow[2,])), col="darkblue", labels=as.numeric(risk.dataLow[3,]))
  text( risk.dataHigh[2,], rep(-0.1, length(risk.dataHigh[2,])), col="red", labels=as.numeric(risk.dataHigh[3,]))
  dev.off()


}
