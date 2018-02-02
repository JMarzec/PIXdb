# Mapping most variable probes on GeneIDs
# parameters: expression matrix, array design file, mapping type ("ensembl", "entrez", "gene_name")
MappingProbes <- function(exp.data, adf.data, mapping.type, mapping.dict) {
  ### creating a probe - identifier dataframe
  # probes with no corrispective id are deleted
  ## The gene_name mapping is a 2-step phase: 1) conversion against ensembl (using adf file);
  ## 2) mapping ensembl -- gene_name (using a pre-defined dictionary)
  if (mapping.type == "ensembl" || mapping.type == "gene_name") {
    adf.data.conv = data.frame('probe_name'= rownames(adf.data), 'ensembl'= adf.data[,which(grepl("ensembl",colnames(adf.data)))],stringsAsFactors = FALSE)
    adf.data.conv <- adf.data.conv[-which(adf.data.conv$ensembl == ''), ]
  } else if (mapping.type == "entrez"){
    adf.data.conv = data.frame('probe_name'= rownames(adf.data), 'entrez'= adf.data[,which(grepl("locus",colnames(adf.data)))],stringsAsFactors = FALSE)
    adf.data.conv <- adf.data.conv[-which(is.na(adf.data.conv$entrez)), ]
  }
  
  # merging expr data with adf file information
  exp.data.conv = merge(adf.data.conv, exp.data, by.x = 'probe_name')
  
  # splitting expr dataframe by gene identifier, in order select just most variable probes (with highest iqr)
  if (mapping.type == "ensembl" || mapping.type == "gene_name") {
    splitted.exp.data <- split( exp.data.conv , f = exp.data.conv$ensembl)
    # initializing dataframe with probe name, ensembl code and calculated IQR
    exp.data.iqr = data.frame('probe_name'=character(length(splitted.exp.data)), 'Ensembl.ID'=character(length(splitted.exp.data)), stringsAsFactors = FALSE)
    
    # calculating IQR and selecting just the most variables probes
    for(i in 1:length(splitted.exp.data)) {
      iqr = 0
      probe = ''
      ensembl = splitted.exp.data[[i]]$ensembl[1]
      for(j in 1:nrow(splitted.exp.data[[i]])) {
        tmp_iqr = IQR(splitted.exp.data[[i]][j,3:length(splitted.exp.data[[i]])], na.rm = FALSE, type = 7)
        if (tmp_iqr > iqr) {
          iqr = tmp_iqr
          probe = splitted.exp.data[[i]][j,]$probe_name
        }
      }
      exp.data.iqr$Ensembl.ID[i] <- ensembl
      exp.data.iqr$probe_name[i] <- probe
    }
    
  } else if (mapping.type == "entrez") {
    splitted.exp.data <- split( exp.data.conv , f = exp.data.conv$entrez)
    # initializing dataframe with probe name, entrez code and calculated IQR
    exp.data.iqr = data.frame('probe_name'=character(length(splitted.exp.data)), 'Entrez.ID'=character(length(splitted.exp.data)), stringsAsFactors = FALSE)
    
    # calculating IQR and selecting just the most variables probes
    for(i in 1:length(splitted.exp.data)) {
      iqr = 0
      probe = ''
      entrez = splitted.exp.data[[i]]$entrez[1]
      for(j in 1:nrow(splitted.exp.data[[i]])) {
        tmp_iqr = IQR(splitted.exp.data[[i]][j,3:length(splitted.exp.data[[i]])], na.rm = FALSE, type = 7)
        if (tmp_iqr > iqr) {
          iqr = tmp_iqr
          probe = splitted.exp.data[[i]][j,]$probe_name
        }
      }
      exp.data.iqr$Entrez.ID[i] <- entrez
      exp.data.iqr$probe_name[i] <- probe
    }
  }
  
  ### Second phase (just for gene_name flag) -- Mapping Ensembl to gene_name --#
  if (mapping.type == "gene_name") {
    ### merge iqr file with ensembl_gene dict
    exp.data.iqr = merge(mapping.dict,exp.data.iqr,by="Ensembl.ID")
    exp.data.iqr$Ensembl.ID <- NULL
  } 
  
  return(exp.data.iqr)
}

calculatePam50 <- function(exp.data.category.subset, PAM50.genes) {
  
  # loading required libraries
  suppressMessages(library('genefu'))
  
  # subsetting expression data on pam50 genes
  exp.data.category.subset.pam50 <- na.omit(exp.data.category.subset[rownames(PAM50.genes),])
  # mapping ensembl ids to gene_symbols [necessary for genefu package]
  exp.data.category.subset.pam50 <- na.omit(merge(PAM50.genes["Gene.Symbol"],exp.data.category.subset.pam50,by="row.names",all.x = TRUE))[,-1]
  rownames(exp.data.category.subset.pam50) = exp.data.category.subset.pam50[,1]
  exp.data.category.subset.pam50 <- data.matrix(exp.data.category.subset.pam50[,-1])
  #----------------------------------------#
  
  # Performing subtyping using PAM50
  PAM50Preds <- molecular.subtyping(sbt.model = "pam50",data=t(exp.data.category.subset.pam50), annot=PAM50.genes,do.mapping=FALSE)
  
  return(PAM50Preds)
}

# GET EXPRESSION-DERIVED RECEPTOR STATUS FOR ER, PGR AND HER2
receptor.status <- function( ann.data, gene, col.title, out.file ) {
  
  # for receptor create matrix then add sample names
  tmp.receptor <- as.matrix(rep(0, length(rownames(ann.data) ) ) );
  names(tmp.receptor ) <- rownames(ann.data);
  
  tmp.receptor[pos.data[[gene]]] <- "1";
  
  col.title <- col.title;
  rec <- tmp.receptor;
  rec <- as.matrix(tmp.receptor);
  colnames(rec) <- col.title;
  
  # write back the annot data with new receptor expression by our implementation
  ann.data <- cbind(ann.data, rec);
  
  write.table( ann.data, file = out.file, row.names = T, col.names = NA, sep = "\t" );
  
  return (ann.data);
}

