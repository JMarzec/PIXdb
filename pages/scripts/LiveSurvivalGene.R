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

##### the patiens assignment into low and high expression groups is based on the best cutt-off value as defined in the mehtod introduced in KM Plotter web tool ( http://kmplot.com/analysis/index.php?p=service ; http://kmplot.com/analysis/studies/Supplemental%20R%20script%201.R )
##### set lower and upper values between which to search for the bet cutt-off value
Lower_q <- 0.25
Upper_q <- 0.75

#===============================================================================
#    Main
#===============================================================================

##### splitting exp_file string to retrieve all the identified samples
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

  ##### Extract expression values for selected gene
  gene.sub <- as.matrix(exp.data.slimmed[ gene , ])

  #===============================================================================
  #     Selected the best performing percentile cut-off
  #===============================================================================

  ##### Selected the best performing percentile cut-off based on method introduced in KM plotter web tool ( http://kmplot.com/analysis/studies/Supplemental%20R%20script%201.R )

  ordered_gene = order(gene.sub);
  q1 <- round(length(ordered_gene)*Lower_q);
  q3 <- round(length(ordered_gene)*Upper_q);

  # extract surv data
  surv.stat <- as.numeric( ann.data.slimmed[ , "surv.stat"]);
  # extract surv time
  surv.time <- as.numeric( ann.data.slimmed[ , "surv.time"]);
  # extract surv type
  surv.type <- as.character( ann.data.slimmed[ , "surv.type"])[1];

  surv <- Surv(surv.time, surv.stat);

  p_values <- vector(mode="numeric", length = q3-q1+1)
  cutoffs <- seq(Lower_q,Upper_q, by=(Upper_q-Lower_q)/(q3-q1))
  min_j <- 0
  min_pvalue <- 1

  for (j in q1:q3) {

      gene_expr <- vector(mode="numeric", length=length(gene.sub))
      gene_expr[ordered_gene[j:length(ordered_gene)]] <- 1

      cox <- summary(coxph(surv ~ gene_expr))

      pvalue <- cox$sctest[3]

      p_values[j-q1+1] <- pvalue

      if (pvalue < min_pvalue) {
          min_pvalue <- pvalue
          min_j <- j
      }
  }

  ##### Use selected cut-off devide samples into low and high-expression groups
  rg <- rep("_Low_expression", length=length(gene.sub))
  rg[ordered_gene[min_j:length(ordered_gene)]] <- "_High_expression"
  rg <- factor(rg, levels = c("_Low_expression", "_High_expression"))


  ##### Cox's regression for survival data (univariate analysis)
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
  legend("topleft", legend=c(paste0(gene," low expression"), paste0(gene," high expression")), col=c("darkblue", "red"), lty=c(1,1), lwd=2.5, box.col="transparent", bg="transparent")
  legend("bottom", legend="Number at risk\n\n\n\n", box.col="transparent", bg="transparent")
  text( risk.dataLow[2,], rep(-0.05, length(risk.dataLow[2,])), col="darkblue", labels=as.numeric(risk.dataLow[3,]))
  text( risk.dataHigh[2,], rep(-0.1, length(risk.dataHigh[2,])), col="red", labels=as.numeric(risk.dataHigh[3,]))
  dev.off()



}
