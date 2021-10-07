# PIXdb - Prostate Integrative Expression Database
Analytics features developed for [Prostate Integrative Expression Database](https://pixdb.org.uk) to conduct transcriptomic analyses using publicly available prostate cancer-related data. This includes data obtained from [ArrayExpress](https://www.ebi.ac.uk/arrayexpress/), [Gene Expression Omnibus](https://www.ncbi.nlm.nih.gov/geo/) (GEO), [The Cancer Genome Atlas](https://cancergenome.nih.gov/) (TCGA) and [International Cancer Genome Consortium](http://icgc.org/) (ICGC).

### Analyses scripts

Script | Description | Component
------------ | ------------ | ------------
*[LiveGeneExpression.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveGeneExpression.R)* | Generates box-plots and bar-plots to visualise expression measurments across samples and groups for user-defined gene | Per-dataset
*[LiveGeneExpressionOrdered.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveGeneExpressionOrdered.R)* | Generates box-plots and bar-plots to visualise expression measurments across samples and groups for user-defined gene. The script also allows to define the order of groups as defined in the target files | Per-platform
*[LiveCoExpression.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveCoExpression.R)* | Calculates co-expression of user-defined genes across all samples or samples in user-defined group and presents correlation coefficients between samples as well as associated p-values in a form of correlation matrix heatmap | Per-dataset Per-platform
*[LiveSurvivalGene.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveSurvivalGene.R)* | Performs survival analysis for user-defined gene | Per-dataset
*[LiveNetworkCreator.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveNetworkCreator.R)* | Script for generating interaction networks | Per-dataset Per-platform
*[LiveRankStats.R](https://github.com/JMarzec/PIXdb/tree/master/pages/scripts/LiveRankStats.R)* | Generates bar-plot presenting the integrative analysis results, including the average fold-change (y-axis), combined p-value (bars' annotation) and final rank (bar colour) | Per-dataset Per-platform
<br />


### MySQL database set up

```
mysql -u root -p

CREATE DATABASE pixdb;

use pixdb
```

Create Datasets table
```
CREATE TABLE Datasets (ID INT(11) AUTO_INCREMENT PRIMARY KEY, Platform VARCHAR(20) NOT NULL, DatasetID VARCHAR(20) NOT NULL UNIQUE, PMID VARCHAR(20) UNIQUE  NOT NULL, Title TEXT, Authors TEXT, Journal TEXT, Abstract TEXT, PubDate DATE, Ranking INT(11), Analysis VARCHAR(1000));

CREATE TABLE Datasets_Keywords (DatasetID VARCHAR(20) NOT NULL PRIMARY KEY, KW INT(11) NOT NULL);
```

Create Platforms table
```
CREATE TABLE Platforms (Platform VARCHAR(20) NOT NULL, Name VARCHAR(200) NOT NULL, Total_probes VARCHAR(20), Reliable_probes VARCHAR(20), Reliable_probes_percentage VARCHAR(20), Genes_no INT(11), Datasets VARCHAR(1000) NOT NULL);

CREATE TABLE Platforms_Keywords (PlatformID VARCHAR(20) NOT NULL PRIMARY KEY, KW INT(11) NOT NULL);

CREATE TABLE Keywords (ID INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY, Keyword text NOT NULL, Occurrences INT(11) NOT NULL, Global_Occurrences BIGINT(20) NOT NULL, Level INT(11) NOT NULL, Rank INT(11) NOT NULL);
```

Create Cross_platform table
```
CREATE TABLE Cross_platforms (ensembl_id VARCHAR(20) NOT NULL, hgnc_symbol VARCHAR(200), description VARCHAR(500), chromosome_name VARCHAR(50), band VARCHAR(20), strand VARCHAR(2), start_position VARCHAR(10), end_position VARCHAR(10), rank_TvsN VARCHAR(10), average_log2fc_TvsN VARCHAR(10), combined_p_TvsN VARCHAR(10), rank_HvsN VARCHAR(10), average_log2fc_HvsN VARCHAR(10), combined_p_HvsN VARCHAR(10), rank_TvsH VARCHAR(10), average_log2fc_TvsH VARCHAR(10), combined_p_TvsH VARCHAR(10), rank_TmvsT VARCHAR(10), average_log2fc_TmvsT VARCHAR(10), combined_p_TmvsT VARCHAR(10), rank_MvsT VARCHAR(10), average_log2fc_MvsT VARCHAR(10), combined_p_MvsT VARCHAR(10));
```
<br>


### Populate MySQL database

#### Per-dataset

Addition of TCGA data as an example
```
CREATE TABLE Cross_platforms (ensembl_id VARCHAR(20) NOT NULL, hgnc_symbol VARCHAR(200), description VARCHAR(500), chromosome_name VARCHAR(50), band VARCHAR(20), strand VARCHAR(2), start_position VARCHAR(10), end_position VARCHAR(10), rank_TvsN VARCHAR(10), average_log2fc_TvsN VARCHAR(10), combined_p_TvsN VARCHAR(10), rank_HvsN VARCHAR(10), average_log2fc_HvsN VARCHAR(10), combined_p_HvsN VARCHAR(10), rank_TvsH VARCHAR(10), average_log2fc_TvsH VARCHAR(10), combined_p_TvsH VARCHAR(10), rank_TmvsT VARCHAR(10), average_log2fc_TmvsT VARCHAR(10), combined_p_TmvsT VARCHAR(10), rank_MvsT VARCHAR(10), average_log2fc_MvsT VARCHAR(10), combined_p_MvsT VARCHAR(10));

SELECT * FROM Datasets WHERE pmid=26544944;
```
<br>

#### Per-platform

RNA_seq
```
INSERT INTO Platforms ( Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets ) VALUES ( "RNA_seq", "Illumina HiSeq 2000 / Genome Analyzer II", "-", "-", "-", 52849, "TCGA , ICGC" );

```
<br>

Affy_HuEx1ST
```
INSERT INTO Platforms ( Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets ) VALUES ( "Affy_HuEx1ST", "Affymetrix Human Exon 1.0 ST", "1409213", "928184", "66", 34030, "GSE21034 , GSE29079 , GSE30521 , GSE41408" );
```
<br>

Affy_U133Plus2
```
INSERT INTO Platforms ( Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets ) VALUES ( "Affy_U133Plus2", "Affymetrix Human Genome U133 Plus 2.0", "54253", "37064", "68", 15917, "E-MEXP-1243 , GSE17951 , GSE3325 , GSE45016 , GSE55945" );
```
<br>

Affy_U133A
```
INSERT INTO Platforms ( Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets ) VALUES ( "Affy_U133A", "Affymetrix Human Genome U133A", "22086", "15318", "69", 8938, "E-TABM-26 , GSE32269 , GSE8218" );
```
<br>

Affy_U95Av2
```
INSERT INTO Platforms ( Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets ) VALUES ( "Affy_U95Av2", "Affymetrix Human Genome U95Av2", "12486", "8191", "66", 5781, "BI-GDAC , GSE1431 , GSE6919" );
```
<br>


Check the complete table
```
SELECT * FROM Platforms;
```
<br>


### Update MySQL database using automated script

First, one needs to update the analyses.report file with lists datasets with corresponding analyses
```
vi /Library/WebServer/Documents/PIXdb/pixdb_backoffice/scripts/analyses.report
```

*NOTE*: Make sure to use python3 to run the script *upload_completed_analysis.py*
```
python --version
```

If the python2 is default
```
alias python=python3
```
...or simply execute the command with by calling *python3*
```
python upload_completed_analysis.py  --report analyses.report
```
<br>


### Add datasets

First, and the data with relevant folder structure, e.g.
```
/var/www/html/bioinf/pixdb_backoffice/data/E-MEXP-1243_18596959

 E-MEXP-1243_18596959
 |
 |-norm_files
 | \-1243_1.processed.genename.csv
 |
 |-target_for_estimate.txt
 |-target_for_heatmap.txt
 \-target.txt
```
<br>

1. Annotate genes in the expression matrices using Gene Symbol (initially Ensembl annotation was used)
```
cd /Users/marzec01/Desktop/svn/trunk/phds/Jack/transcriptomics/code

./FilesOverlap.pl -f1 /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/norm_files/Comb_E-MEXP-1243.txt -f2 /Users/marzec01/Desktop/genome_annotation/ensembl_Homo_sapiens.GRCh38.83.gtf.gene_info.txt -c 1 -o /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/norm_files/1243_1.processed.genename.txt
```

2. Generate heatmap using [*GenesHeatmap.R*](https://github.com/JMarzec/PIXdb/tree/master/pixdb_backoffice/scripts/GenesHeatmap.R) script
```
cd Users/marzec01/Desktop/git/PIXdb/pixdb_backoffice/scripts

R --file=./GenesHeatmap.R --args "/Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/norm_files/1243_1.processed.genename.csv" "/Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/target_for_heatmap.txt" "/Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959"
```

3. Run ESTIMATE analysis scripts [*bcntb.estimate.R*](https://github.com/JMarzec/PIXdb/tree/master/pixdb_backoffice/scripts/bcntb.estimate.R) and [*bcntb.plotly.estimate.R*](https://github.com/JMarzec/PIXdb/tree/master/pixdb_backoffice/scripts/bcntb.plotly.estimate.R)
```
Rscript bcntb.estimate.R --exp_file 1243_1.processed.genename.csv --target /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/target_for_estimate.txt  --target2 /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/target.txt --dir /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959

Rscript bcntb.plotly.estimate.R --report /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/estimate.report --dir /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959
```
<br>

4. Run PCA analysis script [*bcntb.pca.R*](https://github.com/JMarzec/PIXdb/tree/master/pixdb_backoffice/scripts/bcntb.pca.R)
```
Rscript bcntb.estimate.R --exp_file 1243_1.processed.genename.csv --target /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/target_for_estimate.txt  --target2 /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959/target.txt --dir /Library/WebServer/Documents/PIXdb_test/pixdb_backoffice/data/E-MEXP-1243_18596959
```
<br>

### Acknowledgements

Huge **credit** goes to [Stefano Pirro](https://scholar.google.it/citations?user=XoSe_vwAAAAJ&hl=en) who designed the portal framework!

<br>
