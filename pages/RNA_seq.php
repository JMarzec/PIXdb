<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = $relative_root_dir."pixdb_backoffice/data/platforms/RNA_seq/";
$result_directory = "$absolute_root_dir/pixdb_backoffice/data/platforms/RNA_seq/";

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
    <br><br>
    
  <div class="container" id="platforms_results">

    <ul>
      <li><a href="#pca">PCA</a></li>
      <li><a href="#purity">Tumour purity</a></li>
      <li><a href="#expression_heatmap">Expression heatmap</a></li>
      <li><a href="#expression_profiles">Expression profiles</a></li>
      <li><a href="#co_expression_analysis">Expression correlations</a></li>
      <li><a href="#gene_networks">Gene networks</a></li>
    </ul>
    
    <div id="pca">
      <div class='description'>
        <p class='pub_det'> Principal component analyses (PCA) transforms the data into a coordinate system and presenting it as an orthogonal projection.
            This reduces the dimensionality of the data, allowing for the global structure and key “components” of variation of the data to be viewed.
            Each point represents the orientation of a sample in the transcriptional space projected on the PCA,
            with different colours representing the biological group of the sample.
        </p>
      </div>

      <iframe class='results' scrolling='no' src='$iframe_directory/pca_2d_1.html'></iframe>
      <iframe class='results' scrolling='no' src='$iframe_directory/pca_3d_1.html'></iframe>
      <iframe class='results' scrolling='no' src='$iframe_directory/pca_bp_1.html'></iframe>

    </div>
    
    <div id="purity">
      <div class='description'>
        <p class='pub_det'> Cancer samples frequently contain a small proportion of infiltrating stromal and immune cells that might not
                       only confound the tumour signal in molecular analyses but may also have a role in tumourigenesis and progression.
                       We apply an algorithm<sup><a href='https://www.ncbi.nlm.nih.gov/pubmed/24113773' target=null>1</a></sup> that infers the tumour purity and the presence of infiltrating stromal/immune cells from gene expression data.
                       A tumour purity value between 0 and 1 is inferred from the calculated stromal score,
                       immune score and estimate score. All of these values are presented as a scatterplot,
                       with a breakdown of scores for each sample available in tabular format from the target file.
        </p>
    </div>
    <!-- putting gene selector -->
    <div class='estimate_container'>
        <iframe class='results' id='estimate' onload='resizeIframe(this)' scrolling='no' src='$iframe_directory/estimate.html'></iframe>
    </div>

    <!-- loading tumor purity datatable -->
    <table id='Estimate' class='table table-bordered results' cellspacing='0' width='100%'>
        <thead>
            <tr>
            <th>Sample name</th>
            <th>Specimen</th>
            <th>Tumour purity</th>
        </thead>
    </tbody>

EOT;
    // loading javascript for the interaction table
    // loading data about the tumour purity
    // opening connection to the target file and saving into an array
    $target_io = fopen("$result_directory/target.txt", "r");
    // saving headers into a variable
    $headers = fgetcsv($target_io, 1000, "\t");
    while (($target = fgetcsv($target_io, 1000, "\t")) !== FALSE) {
        $target = array_combine($headers, $target);
        echo "<tr>"; // opening column row
        // selecting indexes of interface_exists
        // 0 = Sample name, 2 = Specimen, 3 = Tumour Purity
        $fields = array("File_name","Target","TumorPurity");
        foreach ($fields as &$sf) {
            if ($sf == "TumorPurity") { // we are managing the tumour purity number, we want to round it
                $tp = round($target[$sf]*100,2); // round values to 2 digits
                echo "<td>".$tp."</td>";
            } else {
                echo "<td>".$target[$sf]."</td>";
            }
        }
        echo "</tr>"; // closing column row
    }
    fclose($target_io);

    // closing tumour purity table
    echo "    </tbody>
         </table>";
                         
        // loading javascript to load DataTable tumour purity
        echo "<script> LoadDetailDataTable(\"Estimate\", \"Estimate\") </script>";
        
    echo <<< EOT
    </div>
    
    <div id="expression_heatmap">
      <div class='description'>
        <p class='pub_det'> Unsupervised hierarchical clustering of the expression profiles is presented as heatmap with genes and samples
            represented by columns and rows, respectively. The samples charactersitcs are also indicated on the right hand-side. Only the 200 genes
            with the highest expression variance across samples are presented.
        </p>
      </div>

      <iframe class='results' scrolling='no' src='$iframe_directory/heatmap_exp_1.html'></iframe>
    </div>

    <div id="expression_profiles">
      <div class='description'>
        <p class='pub_det'>
          The expression profile of selected gene(s) across comparative groups are presented as both summarised and a
          sample views (boxplots and barplots, respectively).
        </p>
        <br><br>
        <h4> Please select a gene of interest </h4>
        <br>
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>
      
      <!-- putting gene selector -->
      <select id="gea_platforms_sel"> </select>
      <button id="gea_platforms_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='gea_platforms' id='gea_platforms'></div>
      <iframe class='results' id='gea_platforms_sel_box'></iframe>
      <iframe class='results' id='gea_platforms_sel_bar'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("gea_platforms_sel", "", "", "RNA_seq")</script>
      <script>LoadAnalysis("gea_platforms_sel","gea_platforms_run","platforms","","RNA_seq_gene_expression","0")</script>
    </div>

    <div id="co_expression_analysis">
        <div class='description'>
            <p class='pub_det'>
                We offer users the opportunity to identify genes that are co-expressed with their gene(s) of interest.
                This value is calculated using the Pearson Product Moment Correlation Coefficient (PMCC) value.
                Correlations for the genes specified by the user are presented in a heatmap.
            </p>
            <br><br>
            <h4> Please select at least 2 genes of interest (max 50 genes)</h4>
            <br>
            <u class="note"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
            <br><br>
            <!-- putting gene selector -->
            <select multiple id="cea_platforms_sel"> </select>
            <br><br><br>
            <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
            <br><br>
            <textarea id='textcea_platforms_sel' rows='3' cols='80'></textarea>
            <br>
            <button id="cea_platforms_run" class="run"> Run analysis </button>
        </div>
    
        <!-- Loading div -->
        <div class='cea_platforms' id='cea_platforms'></div>
        <iframe class='results' id='cea_platforms_sel_hm'></iframe>
    
        <!-- Calling Javascripts -->
        <script>LoadGeneSelector("cea_platforms_sel", "", "", "RNA_seq")</script>
        <script>LoadAnalysis("cea_platforms_sel","cea_platforms_run","platforms","","RNA_seq_co_expression","1")</script>
    </div>
    
    <div id='gene_networks'>
      <div class='description'>
        <p class='pub_det'>
          Here we present an interactive tool to explore interactions among proteins of interest.
        </p>
        <br><br>
          <table id='network_parameters_container'>
            <tr style='height:70px; vertical-align:top'>
              <td colspan=2>
                <h4> Please select the genes of interest (maximum 5 genes) </h4>
                <br>
                <u class="note"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                <br><br>
                <select multiple id='platforms_net_sel'></select>
                <br><br>
              </td>
            </tr>
            <tr>
              <td>
                <h4> Please select the interaction score threshold </h4>
                <br><br>
                <div id='mentha-score'></div>
                <!-- loading threshold labels -->
                <input type='text' id='min_thr_label' readonly>
                <input type='text' id='max_thr_label' readonly>
              </td>
              <td>
                <button id="platforms_run_net" class="run"> Run analysis </button>
              </td>
            </tr>
          </table>
          <!-- load legend div -->
          <div id='net_legend' title='Network legend' style='display:none'>
            <img src='../images/net_legend.svg'
          </div>
      </div>

      <div class='platforms_net' id='platforms_net'></div>

      <!-- loading graph container when result launched -->
      <div class='network_container' id='GraphContainerNET'>
        <!-- initializing hidden value for random code (useful for changing graph later) -->
        <input type='hidden' id='random_code'/>
        <table>
          <tr>
            <h4> Speciments available in the dataset: </h4><br>
EOT;
      // loading multiple radio buttons according to the speciments into the target file
      $target_io = fopen("$result_directory/target.txt", "r");
      // initilizing array with speciments
      $all_specimens = array();
      // removing first line
      $headers = fgetcsv($target_io, 1000, "\t");
      while (($target = fgetcsv($target_io, 1000, "\t")) !== FALSE) {
        $target = array_combine($headers, $target);
        // here we change the target column to see if the dataset has been curated by Ema or not
        $all_specimens[] = $target["Target"];
      }
      fclose($target_io);
      // uniquing specimens
      $all_specimens = array_unique($all_specimens);

      // listing speciments
      $cont_specimen = 0;
      foreach ($all_specimens as &$specimen) {
        if ($cont_specimen==0) {
          echo "<td style=\"padding-right:10px;\"><input type=\"radio\" name=\"selector\" checked onclick=LoadNetworkGraph('".$cont_specimen."'); />".$specimen."</td>";
        } else {
          echo "<td style=\"padding-right:10px;\"><input type=\"radio\" name=\"selector\" style=\"margin-right:10px;\" onclick=LoadNetworkGraph('".$cont_specimen."'); />".$specimen."</td>";
        }
        $cont_specimen++;
      }

  echo "   </tr>
        </table>";

  echo <<< EOT

        <!-- inserting legend for color nodes -->
        <br><br>
        <img src='../images/question_mark.png' onClick='LoadLegend()' style='width:30px; height:30px'>
        <iframe class='results' id='network_container' onload='resizeIframe(this);'></iframe>

        <!-- loading table with interactions -->
        <table id='network_details' class='table table-bordered results' cellspacing='0' width='100%'>
          <thead>
            <tr>
              <th>Source Gene (SG)</th>
              <th>Expression SG</th>
              <th>Target Gene (TG)</th>
              <th>Expression TG</th>
              <th>PMIDs</th>
          </thead>
          <tbody>
          </tbody>
        </table>
      </div>

      <!-- loading javascripts -->
      <script>LoadScoreSlider('mentha-score')</script>
      <script>LoadGeneSelector('platforms_net_sel','','','RNA_seq')</script>
      <script>LoadAnalysis('platforms_net_sel','platforms_run_net','','','RNA_seq_gene_network','0')</script
    </div>
    
  </div>

<script> LoadSelector() </script>
<script> LoadPlatformsTable() </script>
<script> LoadPlatformsTabs() </script>
      
EOT;
?>
