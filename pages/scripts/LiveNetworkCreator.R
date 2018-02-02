################################################################################
#
#   File name: LiveNetworkCreator.R
#
#   Authors: Stefano Pirro' ( s.pirro@qmul.ac.uk )
#
#   Barts Cancer Institute,
#   Queen Mary, University of London
#   Charterhouse Square, London EC1M 6BQ
#
################################################################################

################################################################################
#
#   Description: Script for generating interaction networks
#
################################################################################

# silent warnings
options(warn=-1)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

### Setting environment for pandoc
Sys.setenv(HOME = "")

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(optparse))
suppressMessages(library(visNetwork))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-n", "--net_file"), action="store", default=NA, type='character',
              help="File containing network interactions"),
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-m", "--min_thr"), action="store", default=NA, type='double',
              help="Minimum threshold for the mentha score (to select interactions)"),
  make_option(c("-M", "--max_thr"), action="store", default=NA, type='double',
              help="Maximum threshold for the mentha score (to select interactions)"),
  make_option(c("-p", "--genes"), action="store", default=NA, type='character',
              help="ID of genes/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

netFile <- opt$net_file
expFile <- opt$exp_file
min_thr <- opt$min_thr
max_thr <- opt$max_thr
annFile <- opt$target
gene_list <- opt$genes
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

# splitting exp_file string to retrieve all the identified samples
exp_files = unlist(strsplit(expFile, ","))

# loading genes of interest
genes = unlist(strsplit(gene_list, ","))
genes = make.names(genes, unique=TRUE)

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)

# splitting annotation data by category
ann.data.splitted <- split(annData, annData$Target)

#==========================================
# Preparing Network data
#==========================================
network_file = read.table(netFile, sep=";", header = TRUE, stringsAsFactors = FALSE, blank.lines.skip = TRUE, fill = TRUE)

# subset mentha network according to genes
mentha_subset <- network_file[network_file$Gene.A == genes | network_file$Gene.B == genes,]

# sort mentha subset according to the interaction score
mentha_subset = mentha_subset[order(mentha_subset$Score, decreasing = TRUE),]
### number of maximum interactions we want to show (disabled for now)
max_interactions = nrow(mentha_subset)
mentha_subset = mentha_subset[1:max_interactions,]
### selecting interactions according to the mentha score thresholds
mentha_subset = mentha_subset[mentha_subset$Score > min_thr & mentha_subset$Score <= max_thr,]

# creating genes array
all_subset_genes <- na.omit(unique(as.character(rbind(mentha_subset$Gene.A, mentha_subset$Gene.B))))

# if no genes are inside the threshold range, we visualise just the selected ones
if (length(all_subset_genes) == 0) {
  all_subset_genes = genes
}

# initialising cont for naming plots
cont = 0

for (group in names(ann.data.splitted)) {
  #================================================
  # Extracting Expression levels for selected genes
  #================================================

  for (j in 1:length(exp_files)) {

    ef = exp_files[j]
    ##### Read file with expression data
    expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)
    selected_samples <- intersect(as.character(ann.data.splitted[[group]]$File_name),colnames(expData))
    expData.subset <- as.data.frame((data.matrix(expData[,colnames(expData) %in% selected_samples])))
    rownames(expData.subset) = make.names(expData$Gene.name, unique=TRUE) # avoiding duplicated gene names

    for (gene in genes) {
      if ( gene %in% all_subset_genes ) {
        if (j == 1) {
          gene.expr <- expData.subset[gene, ]
        } else {
          gene.expr <- cbind(gene.expr, expData.subset[gene, ])
        }
      }
    }
  }

  # selecting average expression level just for genes in the mentha subnetwork
  average_expr = array()
  for (k in 1:length(all_subset_genes)) {
    if (ncol(expData.subset) > 1) {
      if (is.na(expData.subset[all_subset_genes[k],])) {
        average_expr[k] = NA
      } else {
        mean = rowMeans(expData.subset[all_subset_genes[k],])
        average_expr[k] = mean
      }
    } else {
      average_expr[k] = expData.subset[all_subset_genes[k],]
    }
  }


  #================================================
  # Creating interactive table
  #================================================
  # initialising mentha subset dataframe
  mentha_subset.df.dim = nrow(mentha_subset)
  mentha_subset.df = data.frame(source_gene=character(mentha_subset.df.dim),
                                source_expr=numeric(mentha_subset.df.dim),
                                target_gene=character(mentha_subset.df.dim),
                                target_expr=numeric(mentha_subset.df.dim),
                                pmid=character(mentha_subset.df.dim), stringsAsFactors=FALSE)
  for (k in 1:nrow(mentha_subset)) {
    if (ncol(expData.subset) > 1) {
      mentha_subset.df$source_gene[k] = mentha_subset[["Gene.A"]][k]
      mentha_subset.df$source_expr[k] = round(as.numeric(rowMeans(expData.subset[mentha_subset[["Gene.A"]][k], ])), digits=3)
      mentha_subset.df$target_gene[k] = mentha_subset[["Gene.B"]][k]
      mentha_subset.df$target_expr[k] = round(as.numeric(rowMeans(expData.subset[mentha_subset[["Gene.B"]][k], ])), digits=3)
    } else {
      mentha_subset.df$source_gene[k] = mentha_subset[["Gene.A"]][k]
      mentha_subset.df$source_expr[k] = round(as.numeric(expData.subset[mentha_subset[["Gene.A"]][k], ]), digits=3)
      mentha_subset.df$target_gene[k] = mentha_subset[["Gene.B"]][k]
      mentha_subset.df$target_expr[k] = round(as.numeric(expData.subset[mentha_subset[["Gene.B"]][k], ]), digits=3)
    }

    ## building links for PMIDs
    tmp_link = ""
    mentha_pmids = unlist(strsplit(mentha_subset[["PMID"]][k], " "))
    for (pmid in mentha_pmids) {
      tmp_link = paste0(tmp_link,"<span class='pubmed_det'><a href='https://www.ncbi.nlm.nih.gov/pubmed/",pmid,"' target=null>",pmid," </a></span>")
    }
    mentha_subset.df$pmid[k] = tmp_link
  }
  # remove rows where all are NAs
  mentha_subset.df <- mentha_subset.df[!is.na(mentha_subset.df[,1]),]

  # saving json file for the jquery interactive table
  json.filename = paste0(outFolder,"/",hexcode,"_network",cont,".json")
  json.string.header = paste0("{\"draw\":0,\"recordsTotal\":",nrow(mentha_subset.df),",\"recordsFiltered\":",nrow(mentha_subset.df),",\"data\":[")
  total.json.string = ""
  for (k in 1:nrow(mentha_subset.df)) {
    t = ""
    json.string.body = toString(paste0('"',as.character(mentha_subset.df[k,]),'"'))
    t = paste0(t,"[")
    t = paste0(t,json.string.body)
    t = paste0(t,"],")
    total.json.string = paste0(total.json.string,t)
  }
  totalnchars.json.string.body = nchar(total.json.string)
  total.json.string = substr(total.json.string,1,totalnchars.json.string.body-1)
  json.string.footer = "]}"

  final.json.string = paste0(json.string.header, total.json.string, json.string.footer)
  cat(final.json.string, file = json.filename)

  # creating genes (nodes) dataframe -- for visNetwork
  nodes <- data.frame(
    id=1:length(all_subset_genes),
    expr_value = scale(average_expr),
    label=all_subset_genes,
    color="black", # just a sample color
    group="gene",
    shape="circle",
    title = paste0("<a href='http://www.genecards.org/cgi-bin/carddisp.pl?gene=",all_subset_genes,"' target=new><b>", all_subset_genes ,"</b></a><br>
                    <b> Expression Level (z-score): </b>",round(scale(average_expr),digits=3),""),
    shadow = FALSE, stringsAsFactors = FALSE)

  # loading color palette
  rbPalpos <- colorRampPalette(c(rgb(1,0.8,0.4),rgb(1,0,0)))(length(nodes$color[!is.na(nodes$expr_value) & nodes$expr_value > 0]))
  rbPalneg <- colorRampPalette(c(rgb(0,0,1),rgb(0,0.7,1)))(length(nodes$color[!is.na(nodes$expr_value) & nodes$expr_value <= 0]))

  # highlighting selected nodes and creating label groups
  nodes$color[is.na(nodes$expr_value)] = rgb(0.8,0.8,0.8) # light grey
  nodes$group[is.na(nodes$expr_value)] = "Expression NA"
  nodes$color[!is.na(nodes$expr_value) & nodes$expr_value > 0] = rbPalpos
  nodes$group[!is.na(nodes$expr_value) & nodes$expr_value > 0] = "Up-regulated"
  nodes$color[!is.na(nodes$expr_value) & nodes$expr_value <= 0] = rbPalneg
  nodes$group[!is.na(nodes$expr_value) & nodes$expr_value <= 0] = "Down-regulated"
  nodes$color[nodes$label %in% genes] = "yellow" #rgb(0.8,1,0) # yellow
  nodes$group[nodes$label %in% genes] = "Selection"

  # creating edges dataframe
  from = array();
  to = array();

  for (i in 1:nrow(mentha_subset.df)) {
    from = c(from, nodes[mentha_subset.df$source_gene[i] == nodes$label ,"id"])
    to = c(to, nodes[mentha_subset.df$target_gene[i] == nodes$label,"id"])
  }
  edges <- data.frame(from = from, to = to)

  # saving network into a file
  network = visNetwork(nodes, edges, height = "600px", width = "100%") %>%
    #visGroups(groupname = "Expression NA", color = "lightgrey") %>%
    #visGroups(groupname = "Selection", color = "yellow") %>%
    #visGroups(groupname = "Up-regulated", color = "red") %>%
    #visGroups(groupname = "Down-regulated", color = "lightblue") %>%
    #visLegend(width = 0.1, position = "right") %>%
    visEdges(smooth = TRUE, physics = TRUE) %>%
    visPhysics(stabilization = FALSE, solver = "barnesHut") %>%
    visSave(file = paste0(outFolder,"/",hexcode,"_network",cont,".html"), background = "white", selfcontained = FALSE)
  cont = cont + 1
}
