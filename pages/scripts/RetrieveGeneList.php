<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
include('functions.php');

$ae = $_GET["ae"];
$pmid = $_GET["pmid"];
$type_analysis = $_GET["type_analysis"];
$query = strtoupper($_GET["q"]); // query for the search field

// retrieving all the gene expression matrices inside the result directory
if ($type_analysis == "CrossPlatform") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/crossplatform/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($type_analysis == "RNA_seq") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($type_analysis == "Affy_HuEx1ST") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($type_analysis == "Affy_U133Plus2") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($type_analysis == "Affy_U133A") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($type_analysis == "Affy_U95Av2") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($ae == "TCGA") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/TCGA_26544944/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} elseif ($ae == "E-MEXP-1243_GSE17951_GSE3325_GSE45016_GSE55945") {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/E-MEXP-1243_GSE17951_GSE3325_GSE45016_GSE55945/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage

} else {
  $result_directory = "$absolute_root_dir/pixdb_backoffice/data/$ae"."_"."$pmid/norm_files/";
  chdir($result_directory);
  $expr_files = glob("*.genename.csv");
}

// putting all the found genes inside an array
$GeneContainer = array();
foreach ($expr_files as &$ef) {
  $GeneContainer[] = retrieveGeneList($ef);
}

$GeneContainer = array_unique(array_flatten_recursive($GeneContainer));

$data = array();

foreach ($GeneContainer as &$g) {
  if (strpos($g, $query) !== false) {
    $nestedData["id"] = $g;
    $nestedData["text"] = $g;

    $data[] = $nestedData;
  }
}

echo json_encode($data);
