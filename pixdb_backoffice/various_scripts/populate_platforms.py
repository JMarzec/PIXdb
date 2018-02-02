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
    description='Arguments to populate platforms table')
parser.add_argument('--platforms', type=str, nargs=1,
                    help='platforms file where to extract informations')
args = parser.parse_args()

platforms_file = args.platforms[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="root",           # your username
                     passwd="Biotech8886",         # your password
                     db="pixdb")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# opening connection to the file and perform queries
with open(platforms_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        platform = line[0]
        name = line[1]
        probes_no = line[2]
        rel_probes_no = line[3]
        rel_probes_perc = line[4]
        genes_no = line[5]
        datasets = line[6]

        cur.execute("INSERT INTO Platforms(Platform, Name, Total_probes, Reliable_probes, Reliable_probes_percentage, Genes_no, Datasets) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\")" % (platform, name, probes_no, rel_probes_no, rel_probes_perc, genes_no, datasets))

# close connection to the database
db.close()
