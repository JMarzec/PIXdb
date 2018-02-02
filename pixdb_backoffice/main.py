#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage: python main.py
# description: This script collects the automized pipeline of analysis of transcriptomic BCNTBbp portal

# importing libraries
import os
import sys
import argparse
import fnmatch
import subprocess
import re
import time
# importing all the fixed vars from 'myconfig.py'
from myconfig import *

# parsing arguments
parser = argparse.ArgumentParser(
    description='Arguments to load BCNTBbp automatic pipeline of analysis')
parser.add_argument('--pmids', type=str, nargs=1,
                    help='source txt file containing pmids to retrieve data')
args = parser.parse_args()

# retrieving number of pmids as input
tot_pmids = sum(1 for line in open(args.pmids[0], 'r'))


for i, pmid in enumerate(open(args.pmids[0], 'r')):
    pmid = pmid.rstrip()

    # initialising logs
    error_log = []
    performed_analyses = []

    # 1st step: Download ArrayExpress datasets (related to PMIDs)
    print '%s -- %s %d/%d' % (ArrayExpressMessage, pmid, i + 1, tot_pmids)

    # #### Important update, the system will try to perform this operation 4 times (otherwise it will skip the process) -- 2 seconds between one attempt and another
    for x in range(0, 4):  # try 4 times
        # msg.send()
        # perform operations
        print '\tATTEMPT # %d\r' % x
        sys.stdout.flush()
        RetrieveArrayExpressCommand = 'Rscript scripts/retrieve_datasets_from_pmids.R --pmid %s >a.Rout 2>a.Rerr' % pmid
        RetrieveArrayExpressCommandExec = subprocess.call(
            RetrieveArrayExpressCommand, shell=True)

        # check if error
        if x > 4:
            if RetrieveArrayExpressCommandExec is not 0:
                print ArrayExpressMessageError
                RetrieveArrayExpressCommandExecFlag = 1
                error_log.append('ArrayExpressDownload')
                break  # the command tried for more than 4 times, keep calm and go on!
        elif x < 4:
            if RetrieveArrayExpressCommandExec is not 0:
                # wait for 40 seconds before trying to fetch the data again...time sufficient to recover the download
                time.sleep(40)
            else:
                break

    # checking if ArrayExpressDownload succeed
    for Pline in open('data/download_report.txt'):
        pmid_line = Pline.rstrip().split("\t")[0]
        status = Pline.rstrip().split("\t")[1]

        # if succeeded execute analysis
        if pmid_line == pmid and status == "ok":
            # 2nd step: generation of sample description files from sdrf
            for line in open('data/downloaded_genesets.txt'):
                if pmid in line:

                    # calling sdrf file
                    sdrf_filename = '%s/%s' % (line.rstrip(), fnmatch.filter(
                        os.listdir(line.rstrip()), '*.sdrf.txt')[0])
                    # calling the script to generate sample description file
                    print TargetFileMessage
                    CreateTargetFileCommand = 'python scripts/create_target_file.py --sdrf %s --cancer_terms %s --normal_terms %s --highrisk_terms %s --output %s' % (
                        sdrf_filename, cancer_cv_file, normal_cv_file, highrisk_cv_file, line.rstrip())
                    os.system(CreateTargetFileCommand)

                    # Update 2017/06/15 -- Skipping Estimate command if all normal samples
                    # loading target file
                    target_filename = line.rstrip() + '/target.txt'
                    # the cancer flag is switched off.. it will be on if at least one sample is cancer
                    cancer_flag = 0
                    for target_line in open(target_filename):
                        all_elements = target_line.rstrip().split("\t")
                        sample_type = all_elements[2]
                        if sample_type == "cancer":
                            cancer_flag = 1

                    ### FILE PREPARATION PHASE -- here we query GEO database to extract expression matrices ###
                    # retrieve the AE code for calling GEOQuery R script
                    ae_code = line.split('-')[-1].split('_')[0]
                    # Download the expression matrix from GEO
                    print GeoRetrieveMessage

                    # Import update, the system will try to perform this operation 4 times (otherwise it will skip the process) -- 2 seconds between one attempt and another
                    for x in range(0, 4):  # try 4 times
                        # msg.send()
                        # perform operations
                        print '\tATTEMPT # %d\r' % x
                        sys.stdout.flush()
                        GeoGSECommand = 'Rscript scripts/bcntb.ExtractGeoDataset.R --geo_num %s --dir %s/norm_files >a.Rout 2>a.Rerr' % (
                            ae_code, line.rstrip())
                        GeoGSECommandExec = subprocess.call(
                            GeoGSECommand, shell=True)

                        # check if error
                        if x > 3:
                            if GeoGSECommandExec is not 0:

                                # Update 2017/06/12 -- if GEO command fails but we already downloaded the ArrayExpress dataset, we map the
                                # samples on the ArrayExpress downloaded geneset (pay attention to sample names!)
                                print ArrayExpressRecoveryMessage
                                ArrayExpressCommandRecovery = 'Rscript scripts/bcntb.ArrayExpressRecovery.R --pmid %s --sdrf %s --dir %s >a.Rout 2>a.Rerr' % (
                                    PMID, sdrf_filename, line.rstrip())
                                ArrayExpressCommandRecoveryExec = subprocess.call(
                                    ArrayExpressCommandRecovery, shell=True)
                                break  # the command tried for more than 4 times, keep calm and go on!
                            else:
                                ArrayExpressCommandRecoveryExec = 1
                                break
                        elif x < 3:
                            if GeoGSECommandExec is not 0:
                                # wait for 40 seconds before trying to fetch the data again...time sufficient to recover the download
                                time.sleep(40)
                            else:
                                ArrayExpressCommandRecoveryExec = 1
                                break

                        # 2017/06/09 -- Is not useful to complete the analytical section if the script was not able to
                        # download the data from GEO. For this reason we decided to stop the analytical section if the
                        # error flag (from the above section) is switched on.

                    if GeoGSECommandExec == 0 or ArrayExpressCommandRecoveryExec == 0:

                        ### ANALYTICAL SECTION --- calculating Pam50, mclust and estimate tumor purity ###
                        ## getting filenames for expression data extracted from the ArrayExpress Dataset ##
                        expr_filenames = ','.join(fnmatch.filter(os.listdir(
                            '%s/norm_files' % line.rstrip()), '*.processed.txt'))
                        adf_filename = line.rstrip() + '/array.design.final.adf'
                        target_filename = line.rstrip() + '/target.txt'

                        print MappingMessage
                        # UPDATE 2017/06/19 -- We have to put a control on the execution of the mapping.
                        # If it fails, the entire folder will be remove and the analysis will stop

                        # UDPATE 2 -- HG-U133_Plus_2 technology misses the PGR gene (probe not well reported)
                        # for this reason we implemented a workaround, building a custom adf file just for this technology

                        # checking the technology name
                        array_tech_fn = "%s/array_technology.txt" % line.rstrip()
                        for al in open(array_tech_fn, "r"):
                            if "HG-U133_Plus_2" in al:
                                # if the technology is the HG-U133_Plus_2, we point the adf to the precomputed one
                                adf_custom = "support_files/HG-U133_Plus_2.adf"
                                MapCommand = 'Rscript scripts/bcntb.map.R --exp_file %s --adf_file %s --dir %s >a.Rout 2>a.Rerr' % (
                                    expr_filenames, adf_custom, line.rstrip())
                                break
                            else:
                                MapCommand = 'Rscript scripts/bcntb.map.R --exp_file %s --adf_file %s --dir %s >a.Rout 2>a.Rerr' % (
                                    expr_filenames, adf_filename, line.rstrip())
                                break

                        MapCommandExec = subprocess.call(
                            MapCommand, shell=True)

                        # if command succeed
                        if MapCommandExec == 0:

                            # After the map command, we want to pass to other functions the list of mapped expression files (Ensemb, entrez, gene_name)
                            expr_filenames_ensembl = ','.join(fnmatch.filter(os.listdir(
                                '%s/norm_files' % line.rstrip()), '*.processed.ensembl.csv'))
                            expr_filenames_entrez = ','.join(fnmatch.filter(os.listdir(
                                '%s/norm_files' % line.rstrip()), '*.processed.entrez.csv'))
                            expr_filenames_genename = ','.join(fnmatch.filter(os.listdir(
                                '%s/norm_files' % line.rstrip()), '*.processed.genename.csv'))

                            # Launching PCA analysis
                            print PCAMessage
                            PCACommand = 'Rscript scripts/bcntb.pca.R --exp_file %s --target %s --colouring %s --principal_component %s --dir %s >a.Rout 2>a.Rerr' % (
                                expr_filenames_genename, target_filename, "Target", "1", line.rstrip())
                            PCACommand_exec = subprocess.call(
                                PCACommand, shell=True)

                            # checking if command succeed:
                            if PCACommand_exec == 0:
                                # adding the completed analysis to the performed_analyses array
                                performed_analyses.append('PCA')
                            else:
                                error_log.append('PCA')

                            # launching Estimate command and subprocesses just if cancer flag is ON
                            if cancer_flag == 1:

                                # Launching Estimate analysis
                                print EstimateMessage
                                EstimateCommand = 'Rscript scripts/bcntb.estimate.R --exp_file %s --target %s --dir %s >a.Rout 2>a.Rerr' % (
                                    expr_filenames_entrez, target_filename, line.rstrip())
                                EstimateCommand_exec = subprocess.call(
                                    EstimateCommand, shell=True)

                                # checking if command succeed:
                                if EstimateCommand_exec == 0:
                                    # we can launch the command for plotting in this case:
                                    estimate_report_str = "%s/%s" % (
                                        line.rstrip(), "estimate.report")
                                    EstimatePlot = 'Rscript scripts/bcntb.plotly.estimate.R --report %s --dir %s >a.Rout 2>a.Rerr' % (
                                        estimate_report_str, line.rstrip())
                                    subprocess.call(EstimatePlot, shell=True)

                                    # adding the completed analysis to the performed_analyses array
                                    performed_analyses.append('Tumour purity')

                                    # Launching PAM50 analysis
                                    print PAM50Message
                                    time.sleep(5)
                                    Pam50Command = 'Rscript scripts/bcntb.pam50.R --exp_file %s --target %s --pam50 %s --dir %s >a.Rout 2>a.Rerr' % (
                                        expr_filenames_entrez, target_filename, pam50_file, line.rstrip())
                                    Pam50Command_exec = subprocess.call(
                                        Pam50Command, shell=True)

                                    # checking if command succeed:
                                    if Pam50Command_exec == 0:
                                        # we can launch the command for plotting in this case:
                                        pam50_report_str = "%s/%s" % (
                                            line.rstrip(), "pam50.report")
                                        Pam50plot = 'Rscript scripts/bcntb.plotly.pam50.R --report %s --dir %s >a.Rout 2>a.Rerr' % (
                                            pam50_report_str, line.rstrip())
                                        subprocess.call(Pam50plot, shell=True)

                                        # adding the completed analysis to the performed_analyses array
                                        performed_analyses.append(
                                            'Molecular classification')
                                    else:
                                        # reporting error
                                        print PAM50Error
                                        error_log.append(
                                            'Molecular classification')

                                    # Launching Mclust analysis
                                    print MclustMessage
                                    time.sleep(5)
                                    MclustCommand = 'Rscript scripts/bcntb.mclust.R --exp_file %s --target %s --dir %s >a.Rout 2>a.Rerr' % (
                                        expr_filenames_entrez, target_filename, line.rstrip())
                                    MclustCommand_exec = subprocess.call(
                                        MclustCommand, shell=True)

                                    # checking if command succeed:
                                    if MclustCommand_exec == 0:
                                        # we can launch the command for plotting in this case:
                                        mclust_report_str = "%s/%s" % (
                                            line.rstrip(), "mclust.report")
                                        MclustPlot = 'Rscript scripts/bcntb.plotly.mclust.R --report %s --dir %s >a.Rout 2>a.Rerr' % (
                                            mclust_report_str, line.rstrip())
                                        subprocess.call(MclustPlot, shell=True)

                                        # adding the completed analysis to the performed_analyses array
                                        performed_analyses.append(
                                            'Receptor status')

                                    else:
                                        # reporting error
                                        print MclustError
                                        error_log.append('Receptor status')

                            else:
                                # reporting error
                                print EstimateError
                                error_log.append('Tumour purity')
                                # if all the samples are normal or high-risk or unknown, the Estimate script will fail.
                                # At this point there is no necessity to continue with PAM50 and mclust

                            # 2017/06/09 -- We want to update the performed analysis on the BCNTBbp database.
                            # for now we just save a file with PMID\tConducted analyses (Survival Analysis)
                            file_io = open("analyses.report", "a")
                            if len(performed_analyses) < 1:
                                file_io.write(
                                    "%s\tExpression profiles,Co-expression analysis,Survival analysis\n" % pmid)
                            else:
                                file_io.write("%s\t%s,Expression profiles,Co-expression analysis,Survival analysis\n" % (
                                    pmid, ','.join(performed_analyses)))
                            file_io.close()
                            # re-initialising the 'performed_analyses' array
                            performed_analyses = []

                            # writing error log file
                            file_io = open("error.log", "a")
                            file_io.write("%s\t%s\n" %
                                          (pmid, ','.join(error_log)))
                            file_io.close()

                            # remove output boxes to avoid problems
                            RemoveErrorContainer()

                        # if MapCommand failed, there is no need to continue, the folder can be removed
                        else:
                            print MapError
                            os.system("rm -r %s" % line.rstrip())

                    ## removing line from "downloaded_genesets" to avoid infinite loops
                    #print("grep -v "%s" data/downloaded_genesets.txt > temp && mv temp data/downloaded_genesets.txt" % line.rstrip())
                    os.system("grep -v \"%s\" data/downloaded_genesets.txt > temp && mv temp data/downloaded_genesets.txt" % line.rstrip())

        # if ArrayExpress download command failed, move on
        elif pmid_line == pmid and status == 'failed':
            print "Download failed for paper %s -- Moving on" % pmid
            os.system("rm -r %s" % line.rstrip())
