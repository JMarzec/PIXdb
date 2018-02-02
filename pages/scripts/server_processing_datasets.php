<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// Features to search
$features = "DatasetID, Platform, PMID, Title, PubDate, Analysis";

/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set

// storing  request (ie, get/post) global array to a variable
$requestData= $_REQUEST;

$columns = array(
// datatable column index  => database column name
	0 =>'DatasetID',
	1 =>'Platform',
	2 => 'PMID',
	3 => 'Title',
	4 => 'PubDate',
	5 => 'Analysis',
);

// getting total number records without any search
$sql = "SELECT $features";
$sql.=" FROM $datasets_table WHERE analysis != \"0\" LIMIT 5000";
//$sql.=" FROM $datasets_table LIMIT 100000";
//echo $sql;
$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");
$totalData = mysqli_num_rows($query);
$totalFiltered = $totalData;  // when there is no search parameter then total number rows = total number filtered rows.

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array
	$nestedData=array();

	$nestedData[] = $row["DatasetID"];
	$nestedData[] = $row["Platform"];
	$nestedData[] = $row["PMID"];
	$nestedData[] = "".substr($row["Title"],0,50)."...";
	$nestedData[] = $row["PubDate"];
	$nestedData[] = $row["Analysis"];

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
