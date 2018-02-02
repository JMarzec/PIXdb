<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// DB table to use
$sTable = 'Keywords';
// Features to search
$features = "ID, Keyword, Occurrences";

/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set


// getting total number records without any search
$sql = "SELECT $features";
$sql.=" FROM $sTable LIMIT 5000";
//echo $sql;
$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array

	$nestedData["ID"] = $row["ID"];
  $nestedData["Keyword"] = $row["Keyword"];
	$nestedData["Occurrences"] = $row["Occurrences"];

	$data[] = $nestedData;
}

echo json_encode($data);
//echo json_last_error_msg();

?>
