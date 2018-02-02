#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage:
# description: This script updtaes the completed analyses on the PED database

# loading libraries
import argparse
import MySQLdb

# parsing arguments
parser = argparse.ArgumentParser(description='Arguments to load the information')
parser.add_argument('--report', type=str, nargs=1, help='report of the analyses')
args = parser.parse_args()

# storing variables
report_file = args.report[0]

# connecting to the database
db = MySQLdb.connect(host="localhost",    # your host, usually localhost
                     user="root",         # your username
                     passwd="Biotech8886",  # your password
                     db="pixdb")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need

### performing the mySQL query for each line in the report file
for line in open(report_file, 'r'):
    line = line.rstrip().split("\t")
    pmid = line[0]
    analyses = line[1]

    ## building mySQL query
    query = "UPDATE %s SET Analysis=\"%s\" WHERE PMID=%s" % ("Datasets", analyses, pmid)
    cur = db.cursor()
    try:
        cur.execute(query)
        db.commit()
        cur.close()
        print(query)
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        print(e)

db.close()
