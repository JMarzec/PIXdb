#!/usr/bin/env python3

import os

# coder: -.- wynstep -.-
__file__ = 'myconfig.py'
__author__ = 'Stefano Pirro'
__institution__ = 'Barts Cancer Institute, QMUL London'
__description__ = "Configuration file for the BCNTBbp framework of analysis"

cancer_cv_file = 'support_files/cancer.cv.txt' # file containing the controlled vocabulary to identify cancer samples
normal_cv_file = 'support_files/normal.cv.txt' # file containing the controlled vocabulary to identify normal samples
highrisk_cv_file = 'support_files/highrisk.cv.txt' # file containing the controlled vocabulary to identify high risk samples
pam50_file = 'support_files/pam50.genes.txt' # file containing the controlled vocabulary to identify normal samples

### Messages
ArrayExpressMessage = '#### Downloading datasets from ArrayExpress'
ArrayExpressRecoveryMessage = '\t\t\t***Recovering ArrayExpress Dataframe...'
MappingMessage = '\t***Mapping probes to Identifiers (Ensembl, Entrez, GeneName)...'
TargetFileMessage = '\t***Creating Target file'
GeoRetrieveMessage = '\t***Downloading GEO Datasets'
PAM50Message = '\t***Running PAM50'
MclustMessage = '\t***Running Mclust'
EstimateMessage = '\t***Running Estimate'
PCAMessage = '\t***Running PCA'

### Error Messages
ArrayExpressMessageError = '\t\t\t***Error in downloading the ArrayExpress Dataframe, the error will be reported'
MclustError = '\t\t\t***Error in executing mclust analysis, the error will be reported'
PAM50Error = '\t\t\t***Error in executing PAM50 analysis, the error will be reported'
EstimateError = '\t\t\t***Error in executing Estimate analysis, the error will be reported'
MapError = '\t\t\t***Error in Mapping the expression matrix, deleting the folder'

def RemoveErrorContainer():
    os.system("rm a.Rout && rm a.Rerr")
