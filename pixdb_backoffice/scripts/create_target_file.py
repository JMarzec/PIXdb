#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage:
# description: This script create the target file for BCNTBbp analyses, from ArrayExpress data

# loading libraries
import argparse
import re # re library is important since we are not sure about the position of some words inside the sdrf file

# parsing arguments
parser = argparse.ArgumentParser(description='Arguments to create target file for BCNTBbp')
parser.add_argument('--sdrf', type=str, nargs=1, help='source sdrf file where to extract target file')
parser.add_argument('--output', type=str, nargs=1, help='directory where to save the target file')
parser.add_argument('--cancer_terms', type=str, nargs=1, help='dictionary file for recognising cancer samples')
parser.add_argument('--normal_terms', type=str, nargs=1, help='dictionary file for recognising normal samples')
parser.add_argument('--highrisk_terms', type=str, nargs=1, help='dictionary file for recognising high risk samples')
args = parser.parse_args()

# storing variables
sdrf_file = args.sdrf[0]

#--- BUILDING MANIPULATING DATA STRUCTURE --#
# manipulating the sdrf file in order to extract desired information
# the aim is to create a dictionary to store informations and manipulate them
sdrf_dictionary_container = []
with open(sdrf_file, 'r') as sdrf_io_stream:
    # storing the header into a variable
    sdrf_header = sdrf_io_stream.readline()

    for line in sdrf_io_stream:
        sdrf_dictionary = {}
        for index, sdrf_els in enumerate(line.rstrip().split('\t')):
            if sdrf_header.rstrip().split('\t')[index] not in sdrf_dictionary.keys():
                sdrf_dictionary[sdrf_header.rstrip().split('\t')[index]] = sdrf_els

        sdrf_dictionary_container.append(sdrf_dictionary)

#### -------------------------------------- ###

###--- Loading specimen controlled vocabularies ---####
# loading cancer specimen controlled vocabulary
cancer_cv_terms = []
for line in open(args.cancer_terms[0], 'r'):
    cancer_cv_terms.append(line.rstrip())
cancer_cv_search = re.compile('|'.join(cancer_cv_terms), re.IGNORECASE)

normal_cv_terms = []
for line in open(args.normal_terms[0], 'r'):
    normal_cv_terms.append(line.rstrip())
normal_cv_search = re.compile('|'.join(normal_cv_terms), re.IGNORECASE)

highrisk_cv_terms = []
for line in open(args.highrisk_terms[0], 'r'):
    highrisk_cv_terms.append(line.rstrip())
highrisk_cv_search = re.compile('|'.join(highrisk_cv_terms), re.IGNORECASE)
#### --------------------------------------------- ####

#### --- Searching for the right key terms inside the sdrf file ---#
# 1st: sample name -- it will be a progressive code made of 'sample_'<num>
# 2nd: file name -- it will store the file name to use to extract data.

all_final_res = []
for i in range(0, len(sdrf_dictionary_container)):
    final_res = {'sample_name': '', 'file_name': '', 'target': ''}
    # Here we assign a simple label to the sample
    final_res['sample_name'] = 'Sample_%d' % i

    ### initialising cancer and normal terms occurrences
    cancer_occ = 0
    normal_occ = 0
    highrisk_occ = 0

    for key in sdrf_dictionary_container[i].keys():
        # searching for file names! First searching for cel files, txt instead (Agilent)
        # Important update, we want to make the script sensible to the presence of GSM... files.
        gsm_file_search = re.search('(GSM\d+)', sdrf_dictionary_container[i][key])
        if gsm_file_search:
           final_res['file_name'] = gsm_file_search.group(0)
        #raw_file_terms = ['^array.+file$']
        #raw_file_search = re.compile('|'.join(raw_file_terms), re.IGNORECASE)
        #if (raw_file_search.search(key)):
        #    cel_file_search = re.search('(\w+.(?i)cel)', sdrf_dictionary_container[i][key])
        #    agilent_file_search = re.search('(\w+.(?i)txt)', sdrf_dictionary_container[i][key])
        #    if cel_file_search:
        #        final_res['file_name'] = cel_file_search.group(0)[0:-4]
        #    elif agilent_file_search:
        #        final_res['file_name'] = agilent_file_search.group(0)[0:-4]

        # searching for key-terms that could help to understand if the sample is tumor, normal or high risk
        #elif (re.search('(?i)comment', key) or re.search('(?i)characteristics', key) or re.search('(?i)description', key)):
        match_cancer = cancer_cv_search.search(sdrf_dictionary_container[i][key])
        match_normal = normal_cv_search.search(sdrf_dictionary_container[i][key])
        match_highrisk = highrisk_cv_search.search(sdrf_dictionary_container[i][key])

        ### Update 2017/06/12 -- the balance between "cancer", "normal" and "high-risk" terms in the file
        # will decide if the sample belongs to the cancer or normal group

        if match_cancer is not None and len(list(filter(None, match_cancer.groups()))) > 0:
            #print '-'.join(filter(None, match_cancer.groups())).lower()
            cancer_occ = cancer_occ + len(list(filter(None, match_cancer.groups())))

        if match_normal is not None and len(list(filter(None, match_normal.groups()))) > 0:
            #print '-'.join(filter(None, match_normal.groups())).lower()
            normal_occ = normal_occ + len(list(filter(None, match_normal.groups())))

        if match_highrisk is not None and len(list(filter(None, match_highrisk.groups()))) > 0:
            #print filter(None, match_highrisk.group()).lower()
            highrisk_occ = highrisk_occ + len(list(filter(None, match_highrisk.groups())))

    #print "cancer occ: %s, normal occ: %s, highrisk occ: %s " % (cancer_occ, normal_occ, highrisk_occ)
    ### assigning the right group to the sample
    if cancer_occ == 0 and normal_occ == 0 and highrisk_occ == 0:
        final_res['target'] = 'unknown'
    else:
        if cancer_occ > normal_occ and cancer_occ > highrisk_occ:
            final_res['target'] = 'cancer'
        elif normal_occ > cancer_occ and normal_occ > highrisk_occ:
            final_res['target'] = 'normal'
        elif highrisk_occ > cancer_occ and highrisk_occ > normal_occ:
            final_res['target'] = 'high-risk'
        elif highrisk_occ == normal_occ:
            final_res['target'] = 'high-risk'
        else:
            final_res['target'] = 'unknown'

    all_final_res.append(final_res)

# Saving final filled structure into a file
file_io = open(args.output[0]+'/target.txt', 'w')
file_io.write('Sample_name\tFile_name\tTarget\n')
for final_res_el in all_final_res:
    file_io.write(final_res_el['sample_name']+'\t'+final_res_el['file_name']+'\t'+final_res_el['target']+'\n')
file_io.close()
