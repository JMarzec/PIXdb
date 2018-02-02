<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// Features to search
$features = "hgnc_symbol, ensembl_id, chromosome_name, band, description, rank_TvsN, rank_TvsN_percentile, average_log2fc_TvsN, combined_p_TvsN, rank_HvsN, rank_HvsN_percentile, average_log2fc_HvsN, combined_p_HvsN, rank_TvsH, rank_TvsH_percentile, average_log2fc_TvsH, combined_p_TvsH, rank_TmvsT, rank_TmvsT_percentile, average_log2fc_TmvsT, combined_p_TmvsT, rank_MvsT, rank_MvsT_percentile, average_log2fc_MvsT, combined_p_MvsT";

/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set

// storing  request (ie, get/post) global array to a variable
$requestData= $_REQUEST;

$columns = array(
// datatable column index  => database column name
	0 => 'hgnc_symbol',
	1 => 'ensembl_id',
	2 => 'chromosome_name',
	3 => 'band',
	4 => 'description',
	5 => 'rank_TvsN_percentile',
    8 => 'rank_HvsN_percentile',
	11 => 'rank_TvsH_percentile',
	14 => 'rank_TmvsT_percentile',
	17 => 'rank_MvsT_percentile',
);

// getting total number records without any search
$sql = "SELECT $features";
$sql.=" FROM $crossplatforms_table";

// error_log($sql);

  
$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");
$totalData = mysqli_num_rows($query);
$totalFiltered = $totalData;  // when there is no search parameter then total number rows = total number filtered rows.

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array
	$nestedData=array();

	$nestedData[] = $row["hgnc_symbol"];
	$nestedData[] = $row["ensembl_id"];
	$nestedData[] = $row["chromosome_name"];
	$nestedData[] = $row["band"];
	$nestedData[] = $row["description"];
	$nestedData[] = $row["rank_TvsN_percentile"];
  	$nestedData[] = $row["rank_HvsN_percentile"];
  	$nestedData[] = $row["rank_TvsH_percentile"];
  	$nestedData[] = $row["rank_TmvsT_percentile"];
  	$nestedData[] = $row["rank_MvsT_percentile"];

	$data[] = $nestedData;
}

$json_data = array(
			"draw"            => intval( $requestData['draw'] ),   // for every request/draw by clientside , they send a number as a parameter, when they recieve a response/data they first check the draw number, so we are sending same number in draw.
			"recordsTotal"    => intval( $totalData ),  // total number of records
			"recordsFiltered" => intval( $totalFiltered ), // total number of records after searching, if there is no searching then totalFiltered = totalData
			"data"            => $data   // total data array
			);

echo json_encode($json_data);  // send data as json format
//echo json_last_error_msg();

?>
