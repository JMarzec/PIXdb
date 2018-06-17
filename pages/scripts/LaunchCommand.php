<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
include('functions.php');

// initialising vars called from ajax
$TypeAnalysis = $_GET["TypeAnalysis"];
$ArrayExpressCode = $_GET["ArrayExpressCode"];
$pmid = $_GET["PMID"];
$genes = $_GET["Genes"];
$unique_id = $_GET["rc"];
// initialising values just for gene networks analysis
$min_thr = $_GET["min_thr"];
$max_thr = $_GET["max_thr"];

$exec_error_flag = 0; // error flag switched off by default

// *** File variables *** //
$result_directory = "$absolute_root_dir/pixdb_backoffice/data/$ArrayExpressCode"."_"."$pmid";
$target_file = "$result_directory/target.txt";
$target_surv_file = "$result_directory/target_surv.txt";
$tmp_dir = "$absolute_root_dir/pixdb_backoffice/tmp";
$R_dir = "/Library/Frameworks/R.framework/Versions/Current/Resources/bin";

echo $absolute_root_dir;

// checking the presence of multiple expression files inside the result Directory
$results_files = glob("$result_directory/norm_files/*.genename.csv");
$results_files_string = '';
if (count($results_files) > 0) {
  foreach ($results_files as &$rf) {
    $results_files_string .= $rf.",";
  }
}
// removing last comma from the results_files simplexml_load_string
$results_files_string = substr($results_files_string, 0, -1);

if ($TypeAnalysis == "gene_expression") {
  // *** Gene Expression Analyses *** //
  // launching Rscript for the analysis...
  // error_log("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $results_files_string --target $target_file --colouring Target --order Normal,HGPIN,Tumour,Tumour_met,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output,0);
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $results_files_string --target $target_file --colouring Target  --order Normal,HGPIN,Tumour,Tumour_met,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  // error_log("Rscript LiveCoExpression.R --exp_file $results_files_string --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $results_files_string --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "survival") {
  // *** Survival Analyses *** //
  // launching Rscript for the analysis...
  // error_log("$R_dir/Rscript LiveSurvivalGene.R --exp_file $results_files_string --target $target_file --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", 0);
  system("$R_dir/Rscript LiveSurvivalGene.R --exp_file $results_files_string --target $target_surv_file --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);
} elseif ($TypeAnalysis == "gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  // launching Rscript for the analysis...
  // error_log("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $results_files_string --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", 0);
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $results_files_string --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "RNA_seq_gene_expression") {
  // *** Gene Expression Analyses for per-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/norm_files/RNA_seq_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/target.txt";
  // error_log("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target  --order Normal,Tumour --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", 0);
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target  --order Normal,Tumour --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "RNA_seq_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/norm_files/RNA_seq_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/target.txt";
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "RNA_seq_gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/norm_files/RNA_seq_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/target.txt";
  // launching Rscript for the analysis...
  //echo "Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1";
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_HuEx1ST_gene_expression") {
  // *** Gene Expression Analyses for per-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/norm_files/Affy_HuEx1ST_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/target.txt";
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target --order Normal,Tumour,Tumour_met --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_HuEx1ST_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/norm_files/Affy_HuEx1ST_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/target.txt";
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_HuEx1ST_gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/norm_files/Affy_HuEx1ST_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_HuEx1ST/target.txt";
  // launching Rscript for the analysis...
  //echo "Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1";
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133Plus2_gene_expression") {
  // *** Gene Expression Analyses for per-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/norm_files/Affy_U133Plus2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/target.txt";
  // error_log("$R_dir/Rscript LiveGeneExpressionOrderted.R --exp_file $expr_file --target $target_file --colouring Target --order Normal,HGPIN,Tumour,Tumour_met,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", 0);
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target --order Normal,HGPIN,Tumour,Tumour_met,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133Plus2_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/norm_files/Affy_U133Plus2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/target.txt";
  // error_log("Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", 0);
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133Plus2_gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/norm_files/Affy_U133Plus2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133Plus2/target.txt";
  // launching Rscript for the analysis...
  //echo "Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1";
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133A_gene_expression") {
  // *** Gene Expression Analyses for per-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/norm_files/Affy_U133A_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/target.txt";
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target --order Normal,Tumour,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133A_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/norm_files/Affy_U133A_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/target.txt";
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U133A_gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/norm_files/Affy_U133A_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U133A/target.txt";
  // launching Rscript for the analysis...
  //echo "Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1";
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U95Av2_gene_expression") {
  // *** Gene Expression Analyses for per-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/norm_files/Affy_U95Av2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/target.txt";
  system("$R_dir/Rscript LiveGeneExpressionOrdered.R --exp_file $expr_file --target $target_file --colouring Target --order Normal,Tumour,Metastasis --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U95Av2_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/norm_files/Affy_U95Av2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/target.txt";
  system("$R_dir/Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

} elseif ($TypeAnalysis == "Affy_U95Av2_gene_network") {
  // *** Gene Network analysis *** //
  $net_file = "$absolute_root_dir/src/mentha.txt";
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/norm_files/Affy_U95Av2_1.processed.genename.csv";
  $target_file = "$absolute_root_dir/pixdb_backoffice/data/platforms/Affy_U95Av2/target.txt";
  // launching Rscript for the analysis...
  //echo "Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1";
  system("$R_dir/Rscript LiveNetworkCreator.R --net_file $net_file --exp_file $expr_file --target $target_file --genes $genes --dir $tmp_dir --hexcode $unique_id --min_thr $min_thr --max_thr $max_thr 2>&1", $output);

} elseif ($TypeAnalysis == "stats_crossplatform") {
  // *** Gene Expression Analyses for cross-platform data *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/pixdb_backoffice/data/crossplatform/Meta_genes_TumourvsNormal_HGPINvsNormal_TumourvsHGPIN_Tumour_metvsTumour_MetastasisvsTumour_DEbound_summary.txt";
  system("$R_dir/Rscript LiveRankStats.R --results_file $expr_file --gene $genes --dir $tmp_dir --hexcode $unique_id 2>&1", $output);

}
