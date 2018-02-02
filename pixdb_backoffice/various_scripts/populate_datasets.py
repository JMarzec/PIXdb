#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage:
# description: This script populates the CCLE database starting from a csv file with all the informations

# loading libraries
import argparse
import MySQLdb

# =============== Parsing arguments ===========================#
parser = argparse.ArgumentParser(
    description='Arguments to create target file for BCNTBbp')
parser.add_argument('--ccle', type=str, nargs=1,
                    help='ccle file where to extract informations')
args = parser.parse_args()

ccle_file = args.ccle[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="root",           # your username
                     passwd="Biotech8886",         # your password
                     db="pixdb")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# opening connection to the file and perform queries
with open(ccle_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        name = line[0]
        target = line[1]
        type_derived_from = line[2]
        gender = line[3]
        ethnicity = line[4]
        age = line[5]
        er = line[6]
        pr = line[7]
        her2 = line[8]

        cur.execute("INSERT INTO ccle(name, target, type_derived_from, gender, ethnicity, age, er, pr, her2) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\")" % (name, target, type_derived_from, gender, ethnicity, age, er, pr, her2))

# close connection to the database
db.close()
