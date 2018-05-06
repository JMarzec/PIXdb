<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = $relative_root_dir."pixdb_backoffice/data/crossplatform/";
$result_directory = "$absolute_root_dir/pixdb_backoffice/data/crossplatform/";

echo <<< EOT
<!-- Results Section -->
  <center>
    <tr>
        <td ><img class="menu_sel" src="../images/bio_comp.png" style="width:70%"/></a></td>
    </tr>
  </center>

    <table id="main_container">
        <tr>
            <td id="right">
                <table id="crossplatform" class="display DataTable compact" cellspacing="0" width="100%">
                    <!-- Table Header -->
                    <thead>
                        <tr>
                            <th>Gene</th>
                            <th>Ensmebl ID</th>
                            <th>Chrom</th>
                            <th>Band</th>
                            <th>Description</th>
                            <th>Rank 1 (%)</th>
                            <th>Rank 2 (%)</th>
                            <th>Rank 3 (%)</th>
                            <th>Rank 4 (%)</th>
                            <th>Rank 5 (%)</th>
                        </tr>
                    </thead>
                    <!-- Table Footer -->
                    <tfoot>
                        <tr>
                            <th>Gene</th>
                            <th>Ensmebl ID</th>
                            <th>Chrom</th>
                            <th>Band</th>
                            <th>Description</th>
                            <th>Rank 1 (%)</th>
                            <th>Rank 2 (%)</th>
                            <th>Rank 3 (%)</th>
                            <th>Rank 4 (%)</th>
                            <th>Rank 5 (%)</th>
                        </tr>
                    </tfoot>
                </table>
            </td>
        </tr>
        <tr colspan=2>
            <td>

            </td>
        </tr>
    </table>

      <div class="container" id="crossplatform_results">
    <ul>
      <li><a href="#volvano">Volvano plots</a></li>
      <li><a href="#stats">Statistics</a></li>
    </ul>

    <div id="volvano">
      <div class='description'>
        <p class='pub_det'> A volcano plot plots the log2 fold-change values (the measure of gene expression change) on the x-axis and the -log10 of the combined P values
        (the measure of the change statistical significance) on the y-axis. Genes (dots) that are highly dysregulated are farther to the left and right sides, while highly
        significant changes appear higher on the plot. Genes are coloured based on their log2 fold-change with the colour key presented on the right-hand side.
        </p>
      </div>
      <br>
      <center>
        <table>
            <tr style='text-align:center'>
                <td>
                    <h3> Select biological comparison </h3>
                </td>
            </tr>
        </table>
      </center>

      <!-- putting group selector -->
      <button class="volcano_crossplatform_sel run" value="TvsN"> Primary tumour vs Benign </button>
      <button class="volcano_crossplatform_sel run" value="HvsN"> HGPIN vs Benign </button>
      <button class="volcano_crossplatform_sel run" value="TvsH"> Primary tumour vs HGPIN </button>
      <button class="volcano_crossplatform_sel run" value="TmvsT"> Metastatic primary tumour vs Primary tumour </button>
      <button class="volcano_crossplatform_sel run" value="MvsT"> Metastasis vs Primary tumour </button>

      <!-- Loading div -->
      <div class='volcano_crossplatform' id='volcano_crossplatform'></div>
      <iframe class='results' id='volcano_crossplatform_sel_box' style='width:950px;height:700px;margin-left:20px;margin-top:20px'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadAnalysis("","volcano_crossplatform_sel","crossplatform","","crossplatform_volcano","1")</script>

    </div>

    <div id="stats">
      <div class='description'>
        <p class='pub_det'>
          The cross-platform integrative analysis results, including log2 fold-change and combined P (-log10) values, for selected gene in various biological comparisons are presented in a form of
          barplot. The colour of each bar relects the gene's rank indicating its evidence for aberrant expression in corresponding comparison.
          The colour key is presented on the right-hand side.
        </p>
        <br><br>
        <h4> Please select a gene of interest </h4>
        <br>
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>

      <!-- putting gene selector -->
      <select id="stats_crossplatform_sel"> </select>
      <button id="stats_crossplatform_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='stats_crossplatform' id='stats_crossplatform'></div>
      <iframe class='results' id='stats_crossplatform_sel_bar'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("stats_crossplatform_sel", "", "", "CrossPlatform")</script>
      <script>LoadAnalysis("stats_crossplatform_sel","stats_crossplatform_run","crossplatform","","stats_crossplatform","0")</script>
    </div>

    <script> LoadCrossPlatformTable() </script>
    <script> LoadCrossPlatformTabs() </script>
EOT;

// MeSH filter disabled for now
/*
  <!-- MeSH term filter (disabled for now) -->
  <tr>
      <td>
          <input id="mesh_filter"/>
      </td>
  </tr>
  <!-- ------------------------- -->
*/
?>