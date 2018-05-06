#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage:
# description: This script populates the TCGA database starting from a csv file with all the informations

# loading libraries
import argparse
import MySQLdb

# =============== Parsing arguments ===========================#
parser = argparse.ArgumentParser(
    description='Arguments to populate Cross_platforms table')
parser.add_argument('--cross_platforms', type=str, nargs=1,
                    help='cross_platforms file where to extract informations')
args = parser.parse_args()

cross_platforms_file = args.cross_platforms[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="root",           # your username
                     passwd="Biotech8886",         # your password
                     db="pixdb")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
db.autocommit(True)
cur = db.cursor()

# opening connection to the file and perform queries
with open(cross_platforms_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        ensembl_id = line[0]
        hgnc_symbol = line[1]
        description = line[2]
        chromosome_name = line[3]
        band = line[4]
        strand = line[5]
        start_position = line[6]
        end_position = line[7]
        rank_TvsN = line[8]
        rank_TvsN_percentile = line[9]
        average_log2fc_TvsN = line[10]
        combined_p_TvsN = line[11]
        rank_HvsN = line[12]
        rank_HvsN_percentile = line[13]
        average_log2fc_HvsN = line[14]
        combined_p_HvsN = line[15]
        rank_TvsH = line[16]
        rank_TvsH_percentile = line[17]
        average_log2fc_TvsH = line[18]
        combined_p_TvsH = line[19]
        rank_TmvsT = line[20]
        rank_TmvsT_percentile = line[21]
        average_log2fc_TmvsT = line[22]
        combined_p_TmvsT = line[23]
        rank_MvsT = line[24]
        rank_MvsT_percentile = line[25]
        average_log2fc_MvsT = line[26]
        combined_p_MvsT = line[27]

        cur.execute("INSERT INTO Cross_platforms(ensembl_id, hgnc_symbol, description, chromosome_name, band, strand, start_position, end_position, rank_TvsN, rank_TvsN_percentile, average_log2fc_TvsN, combined_p_TvsN, rank_HvsN, rank_HvsN_percentile, average_log2fc_HvsN, combined_p_HvsN, rank_TvsH, rank_TvsH_percentile, average_log2fc_TvsH, combined_p_TvsH, rank_TmvsT, rank_TmvsT_percentile, average_log2fc_TmvsT, combined_p_TmvsT, rank_MvsT, rank_MvsT_percentile, average_log2fc_MvsT, combined_p_MvsT) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");" % (ensembl_id, hgnc_symbol, description, chromosome_name, band, strand, start_position, end_position, rank_TvsN, rank_TvsN_percentile, average_log2fc_TvsN, combined_p_TvsN, rank_HvsN, rank_HvsN_percentile, average_log2fc_HvsN, combined_p_HvsN, rank_TvsH, rank_TvsH_percentile, average_log2fc_TvsH, combined_p_TvsH, rank_TmvsT, rank_TmvsT_percentile, average_log2fc_TmvsT, combined_p_TmvsT, rank_MvsT, rank_MvsT_percentile, average_log2fc_MvsT, combined_p_MvsT))

# close connection to the database
db.close()
