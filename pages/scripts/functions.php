<?php

/* Functions for Research Portal resource *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This page lists all the functions necessary for the BoB portal*/

// function to make flat a recursive array
function array_flatten_recursive($array) {
   if (!$array) return false;
   $flat = array();
   $RII = new RecursiveIteratorIterator(new RecursiveArrayIterator($array));
   foreach ($RII as $value) $flat[] = $value;
   return $flat;
 }

// given a specific expression file, the function extracts all the gene names
// maps all the needed information and return this as an hash
function retrieveGeneList($expr_file) {
  $GeneDetailsContainer = array();

  // extracting list of genes from the expression file
  // opening the connection to the file
  $stream = fopen("$expr_file", "r");

  // removing first line
  fgetcsv($stream, 1000, "\t");
  while (($file = fgetcsv($stream, 1000, "\t")) !== FALSE) {
    $GeneDetailsContainer[] = $file[0];
  }

  // iterating into the file and extracting the gene names
  //while (($line = fgetcsv($stream, 1000, "\t")) !== FALSE) {
      //$GeneDetailsContainer[] = $line[0];
  //{
  //
  // return($GeneDetailsContainer);
  return($GeneDetailsContainer);
}

?>
