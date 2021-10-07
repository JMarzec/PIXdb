<?php

/* Index page for the BOB portal (Breast Now Bioinformatics) *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This is the main page for all the bioinformatics analysis inside the Research Portal */

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// https://cdn.datatables.net/v/ju/pdfmake-0.1.27/dt-1.10.15/af-2.2.0/b-1.3.1/b-colvis-1.3.1/b-flash-1.3.1/b-html5-1.3.1/b-print-1.3.1/cr-1.3.3/fc-3.2.2/fh-3.1.2/kt-2.2.1/r-2.1.1/rg-1.0.0/rr-1.2.0/sc-1.4.2/se-1.2.2/datatables.min.css"/>

// Header and body sections
echo <<< EOT
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>Prostate Integrative Expression Database</title>

            <!-- CSS LINKS -->
            <link rel="stylesheet" type="text/css" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
            <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.15/css/jquery.dataTables.css"/>
            <link rel="stylesheet" href="../styles/easy-autocomplete.css">

            <!-- SELECT2 PLUGIN -->
            <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
            <!-- CHOSEN PLUGIN -->
            <link href="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.7.0/chosen.css" rel="stylesheet" />

            <!-- MAIN CSS -->
            <link rel="stylesheet" type="text/css" href="../styles/datatables_additional.css">
            <link rel="stylesheet" type="text/css" href="../styles/bob.css">
            <link rel="stylesheet" type="text/css" href="../styles/pixdbstyle.css">

            <!-- JS LINKS -->
            <!-- Loading Jquery -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.js"></script>
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.15/js/jquery.dataTables.js"></script>
            <script type="text/javascript" src="https://d3js.org/d3.v3.min.js"></script>

            <!-- SELECT2 PLUGIN -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.full.js"></script>
            <!-- CHOSEN PLUGIN -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.7.0/chosen.jquery.js"></script>

            <!-- PLUGINS FOR EXPORTING TABLE DATA -->
            <script src="https://cdn.datatables.net/buttons/1.3.1/js/dataTables.buttons.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
            <script src="https://cdn.rawgit.com/bpampuch/pdfmake/0.1.27/build/pdfmake.min.js"></script>
            <script src="https://cdn.rawgit.com/bpampuch/pdfmake/0.1.27/build/vfs_fonts.js"></script>
            <script src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>

            <!-- Loading personal scripts -->
            <script type="text/javascript" src="../js/jquery.dataTables.yadcf.js"></script>
            <script type="text/javascript" src="../js/jquery.easy-autocomplete.js"></script>
            <script type="text/javascript" src="../js/jquery-ui.accordion.multiple.js"></script>
            <script type="text/javascript" src="../js/jquery.scrollIntoView.js"></script>
            <script type="text/javascript" src="../js/jquery.ui.autocomplete.scroll.js"></script>
            <script type="text/javascript" src="../js/bob.js"></script>
            <script type="text/javascript" src="../js/sunburst.js"></script>
    </head>

    <body>
        <!-- ---------------------- -->
        <!-- NAVIGATION MENU -->
<div id="biomart-top-wrapper">
<div id="snpalizer-header">
  <div id="snpalizer-header-2">
	<div class="wrapper">
		<div id="header">
		  <div id="toolbar">
		     <div class="right">
		          <div class="module   first last">
			<a target="_blank" href="http://www.smd.qmul.ac.uk/"><img title="Barts and the London" alt="barts-and-london_sml" src="../images/barts-and-london_sml.png" style="border:0"></a>
		          </div>
		     </div>
		  </div>
		<div id="headermid">
			<div id="logo">
			<p><img src="../images/pixdb_logo.png" alt="Prostate Integrative Expression Database" title="Prostate Integrative Expression Database" style="width:395px;height:144px;border:0"></p>
			</div>
			<div id="banner">
				<a target="_blank" href="http://www.bci.qmul.ac.uk/"><p><img src="../images/bci_logo.png" alt="Barts Cancer Institute" title="Barts Cancer Institute" style="border:0"></a></p>
			</div>
		</div>
		</div>
	</div>
 </div>
</div>

<ul id="snpalizer-nav-list">
<li><a href="/PIXdb/pages/index.php">Home</a></li>
<li><a href="/PIXdb/pages/help.php">User Guide</a></li>
<li><a href="/PIXdb/pages/citation.php">Citation</a></li>
<li><a href="mailto:jacek.marzec@unimelb.edu.au">Contact</a></li>
</ul>

        <div class="container" id="source"> </div>

        <!-- ---------------------------------------- -->
        <script> LoadHomePage() </script>

        <script> LoadMenuSelector() </script>

    <div id="snpalizer_bottom_bar" >
      <span class="tab"></span><span class="tab">Copyright &copy; 2021 Barts Cancer Institute</span>
    </div>
    </div>
    </body>
EOT;

// Footer section
echo <<< EOT


</html>
EOT;

// Google Analytics section (filled once the website is completed)
//
//

?>
