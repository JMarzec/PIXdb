<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = $relative_root_dir."pixdb_backoffice/data/platforms/";
$result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/";

echo <<< EOT
  <!-- Results Section -->
    <table id="platforms" class="display DataTable compact" cellspacing="0" width="100%">
        <!-- Table Header -->
        <thead>
            <tr>
                <th>Platform</th>
                <th>Platform full name</th>
                <th>Total probes</th>
                <th>Reliable probes</th>
                <th>Genes</th>
                <th>Datasets</th>
            </tr>
        </thead>
        <!-- Hide Table Footer
        <tfoot>
            <tr>
                <th>Platform</th>
                <th>Platform full name</th>
                <th>Total probes</th>
                <th>Reliable probes</th>
                <th>Genes</th>
                <th>Datasets</th>
            </tr>
        </tfoot>
         -->
    </table>
    
    <center>
      <table>
        <tr style='text-align:center'>
          <td>
            <h3> Select platform </h3>
          </td>
        </tr>
        <tr>
            <td>
                <button class="analysis_sel" id="RNA_seq"> RNA-seq </button>
                <button class="analysis_sel" id="Affy_HuEx1ST"> Affy HuEx1ST </button>
                <button class="analysis_sel" id="Affy_U133Plus2"> Affy U133Plus2 </button>
                <button class="analysis_sel" id="Affy_U133A"> Affy U133A </button>
                <button class="analysis_sel" id="Affy_U95Av2"> Affy U95Av2 </button>
            </td>
        </tr>
      </table>
    </center>
        
<div class="container" id="main"></div>
<div class="container" id="loading"></div>
<div class="container" id="results"></div>


<script> LoadPlatformsTable() </script>
<script> LoadPlatformsSelector() </script>

EOT;
?>
