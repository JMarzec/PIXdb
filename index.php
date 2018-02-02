<?php

/* Index page for the Research Portal *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This page can be considered the high level hub for all the other subpages contained into the website
 * This webiste is developed according to a one-page layout. A top-right menu (with transparent background) allow
 * to access to other important sections. */

// Header section
echo <<< EOT
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>Welcome to Bioinformatics Portal</title>

            <!-- CSS LINKS -->
            <link rel="stylesheet" type="text/css" href="styles/sf.css">

            <!-- JS LINKS -->
            <!-- Loading Jquery -->
            <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
            <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>

            <!-- Loading personal scripts -->
            <script type="text/javascript" src="js/jquery.fullPage.js"></script>
            <script type="text/javascript" src="js/sf.js"></script>

    </head>
EOT;

// Body section
echo <<< EOT
    <body>
        <!-- NAVIGATION MENU -->
        <div id="menu">
            <table id="menu_cont">
                <tr>
                    <td style='width:70%'><img id="front_logo_small" src="images/ped_logo.png"/></td>
                    <td style='width:30%'>
                        <a href="#select" class='menu_btn' title="Read the documentation"><img class="menu_icon" src="images/icons/doc.png"/></a>
                        <a href="#select" class='menu_btn' title="Contact us"><img class="menu_icon" src="images/icons/about.png"/></a>
                        <a href="#home" class='menu_btn' title="Return to Home"><img class="menu_icon" src="images/icons/home.png"/></a>
                    </td>
                </tr>
            </table>
        </div>
        <!-- ------------- -->

        <!--<div id="fullpage">
            <div class="section" id="section0">
                <table id="s0_org">
                    <tr>
                        <td> <img id="front_logo" src="images/front_logo.png"/> </td>
                    </tr>
                    <tr>
                        <td>
                            <form>
                                <button id="start" formaction="#select"> Start </button>
                            </form>
                        </td>
                    </tr>
                </table>
            </div>-->
            <div class="section" id="section1">
                <table id="s1_org">
                    <!--<tr>
                        <td colspan=2><h1>Which section of the portal you want to explore?</h1></td>
                    <tr>-->
                    <tr>
                        
                        <td><a href="#" ><img class="menu_sel" src="images/literature.png" style="width:70%"/></a></td>
                        <td ><a href="pages/bob.php"><img class="menu_sel" src="images/ped_logo.png" style="width:50%"/></a></td>
                    </tr>
                    <tr>
                        
                    </tr>
                </table>
            </div>
            <div class="section" id="about">
            </div>
        </div>
    </body>

EOT;

// Footer section
echo <<< EOT

</html>
EOT;

// Google Analytics section (filled once the website is completed)

?>
