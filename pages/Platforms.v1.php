<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

echo <<< EOT
    <table id="main_container">
        <tr>
            <td id="left">
                <div id="filter">
                    <!-- Filter controls for the literature table -->
                    <h3>Filter</h3>
                        <table>
                            <tr>
                                <td>
                                    <div id="bioinfo_filter" style="width:200px">
                                      <p class="filter_desc"> Available platforms </p>
                                    </div>
                                </td>
                            </tr>
                        </table>
                </div>
                <div id="analysis_button">
                    <button class='analysis_sel' id='run'> Start analysis </button>
                </div>
                <!-- ---------------------------------------- -->
            </td>
            <td id="right">
                <table id="papers" class="display compact" cellspacing="0" width="100%">
                    <!-- Table Header -->
                    <thead>
                        <tr>
                            <th>Platform</th>
                            <th>Datasets</th>
                            <th>Datasets</th>
                            <th>Datasets</th>
                        </tr>
                    </thead>
                    <!-- Table Footer -->
                    <tfoot>
                        <tr>
                            <th>Platform</th>
                            <th>Datasets</th>
                            <th>Datasets</th>
                            <th>Datasets</th>
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

    <script> LoadPlatformsTable() </script>
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
