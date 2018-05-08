<?php

/* Vars for Research Portal resource *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This page lists all the variables necessary for mySQL database connection and other*/

// connection vars to mySQL database for PIXdb
$bob_mysql_address='127.0.0.1';
$bob_mysql_username='root';
$bob_mysql_password='XXXX'; // in next release, the password will be encrypted
$bob_mysql_database='pixdb';

// tables
$datasets_table = "Datasets";
$keywords_table = "Keywords";
$datasets_keywords_table = "Datasets_Keywords";
$platforms_table = "Platforms";
$platforms_keywords_table = "Platforms_Keywords";
$crossplatforms_table = "Cross_Platforms";

// initialising directories
$relative_root_dir = "http://".$_SERVER['SERVER_NAME']."/PIXdb/";
$absolute_root_dir = $_SERVER['DOCUMENT_ROOT']."/PIXdb";

?>
