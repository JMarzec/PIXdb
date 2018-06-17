<?php

  //ini_set('display_errors',1);
  //ini_set('display_startup_errors',1);
  //error_reporting(-1);

  // loading_results.php
  // report the available results for each paper, according to what has been analysed

  $pmid = $_GET["pmid"];

  // importing variables file
  include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
  include('functions.php');

  /** * MySQL connection */
  $conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
  $conn->set_charset("utf8"); // setting the right character set

  // dynamical listing the datasets downloaded (related to the selected PMID)
  $geo_folders = glob("$absolute_root_dir/pixdb_backoffice/data/*_$pmid*", GLOB_ONLYDIR); // note: the Directory may vary

  // extracting just the ArrayExpress accession
  $ae_accessions = array();
  //print_r($geo_folders);
  //echo $absolute_root_dir;
  //echo "geo_folders: $ae_accessions";
  foreach ($geo_folders as &$gf) {
    //echo $gf;
    $ae_accessions[] = explode("_", end(explode("/", $gf)))[0];
  }
  //print_r($ae_accessions);

  // extracting information from PMID
  $features = "PMID, Title, Journal, Authors, Abstract, PubDate, Analysis";
  $pub_info_query = "SELECT $features";
  $pub_info_query.= " FROM $datasets_table WHERE PMID=$pmid";
  $query=mysqli_query($conn, $pub_info_query) or die("Sorry, cannot perform the query. Please make sure that you select study of interest from the panel list of publications above");

  
echo "<div class=container id='literature'>
        <h1> Publication Details </h1>
      ";
  /* PRESENTING PUBLICATION DETAILS */
  while( $row=mysqli_fetch_array($query) ) {
    echo "<h4> PMID </h4> <p class='pub_det'>".$row["PMID"]."</p><br>";
    echo "<h4> Title </h4> <p class='pub_det'>".$row["Title"]."</p><br>";
    echo "<h4> Journal </h4> <p class='pub_det'>".$row["Journal"]."</p>";
    echo "<h4> Pub. Date </h4> <p class='pub_det'>".$row["PubDate"]."</p><br>";
    echo "<h4> Authors </h4> <textarea readonly id='authors' rows='2' cols='100'>".str_replace("&apo;","'",$row["Authors"])."</textarea><br><br>";
    echo "<h4> Abstract </h4> <textarea readonly id='abstract' rows='10' cols='100'>".str_replace("&apo;","'",$row["Abstract"])."</textarea><br><br>";

    echo "<p class='pub_det'> This publication contains <b>".count($ae_accessions)."</b> datasets. Please refer to the paper for further details.</p><br>";
    echo "<center><a class='papers_link' href='https://www.ncbi.nlm.nih.gov/pubmed/".$row["PMID"]."' target='null'> Read the paper</a></center>";

    $all_performed_analyses = explode(",",$row["Analysis"]);
    $cohort = $row["Cohort"];
    $all_performed_groups = explode(",",$row["Groups"]);
  }
echo "</div>
<div id='res_acc'> ";

  // We decided to put results in a one-page style, with multiple tabs to split the types of analysis
  // initializing cont
  $cont = 0;
  foreach ($ae_accessions as $ae) {
    echo "<h3>$ae</h3>";
    // initializing divs
    echo "<div class='section' id='section_$cont'>";

      /* initialising the tabs with all the performed analysis (Note: for multiple superseries,
      if not all the analysis have been produced for both, an error page will appear) */
      echo "<div id='tabs_s$cont' >
              <ul>";
      foreach ($all_performed_analyses as $pa) {
        $pa_web = str_replace(' ', '_', $pa);
        echo "  <li><a href='#$pa_web$cont'> $pa </a></li>";
      }
      echo "  </ul>";

      // SETTING UP FOLDER NAME WHERE TO LOOK
      $result_directory = "$absolute_root_dir/pixdb_backoffice/data/$ae"."_"."$pmid";
      $expr_directory = $result_directory."/norm_files";
      $iframe_directory = $relative_root_dir."pixdb_backoffice/data/$ae"."_"."$pmid";

      // opening connection to the target file and saving into an array
      $target_io = fopen("$result_directory/target.txt", "r");

      // initialising sections for the results
      foreach ($all_performed_analyses as $pa) {
        $pa_web = str_replace(' ', '_', $pa);
        // checking the type of analysis
        // the content of tabs is different for each analysis type

        if ($pa == "Tumour purity") {
         echo "<div id='$pa_web$cont'>
                 <div class='description'>
                   <p class='pub_det'> Cancer samples frequently contain a small proportion of infiltrating stromal and immune cells that might not
                       only confound the tumour signal in molecular analyses but may also have a role in tumourigenesis and progression.
                       We apply an algorithm<sup><a href='https://www.ncbi.nlm.nih.gov/pubmed/24113773' target=null>1</a></sup> that infers the tumour purity and the presence of infiltrating stromal/immune cells from gene expression data.
                       A tumour purity value between 0 and 1 is inferred from the calculated stromal score,
                       immune score and estimate score. All of these values are presented as a scatterplot,
                       with a breakdown of scores for each sample available in tabular format from the target file.
                   </p>
                 </div>";

               // checking if the file for the analysis is available
               if (file_exists("$result_directory/estimate.html")) {
                 echo "<div class='estimate_container'>
                         <iframe class='results' id='estimate' scrolling='no' src='$iframe_directory/estimate.html'></iframe>
                       </div>";

                 // loading tumor purity datatable
                 echo "<table id='Estimate$cont$pmid' class='table table-bordered results' cellspacing='0' width='100%'>
                         <thead>
                           <tr>
                             <th>Sample name</th>
                             <th>Specimen</th>
                             <th>Tumour purity</th>
                         </thead>
                       </tbody>";

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

               } else {
                 echo "<h3> Sorry no analyses are available </h3>";
               }
         echo "</div>";
         // loading javascript to load DataTable tumour purity
         echo "<script> LoadDetailDataTable(\"Estimate$cont$pmid\", \"Estimate\") </script>";
       }
       elseif ($pa == "PCA") {
          echo "<div id='$pa_web$cont'>
                  <div class='description'>
                    <p class='pub_det'> Principal component analyses (PCA) transforms the data into a coordinate system and presenting it as an orthogonal projection.
                        This reduces the dimensionality of the data, allowing for the global structure and key “components” of variation of the data to be viewed.
                        Each point represents the orientation of a sample in the transcriptional space projected on the PCA,
                        with different colours representing the biological group of the sample.
                    </p>
                  </div>";

                  // NB: Multiple PCA analyses can be present in the results (different expression files)
                  // for this reason we list all the PCAs
                  chdir($result_directory);
                  $pca_files = glob("pca*.html");
                  if (count($pca_files) > 0) {
                    foreach ($pca_files as &$pca_file) {
                      echo "<div class='pca_container'>
                              <iframe class='results' scrolling='no' src='$iframe_directory/$pca_file'></iframe>
                            </div>";
                    }
                  } else {
                     echo "<h3> Sorry no analyses are available </h3>";
                  }

          echo "</div>";
        }
        elseif ($pa == "Expression heatmap") {
          echo "<div id='$pa_web$cont'>
                  <div class='description'>
                    <p class='pub_det'> Unsupervised hierarchical clustering of the expression profiles is presented as heatmap with genes and samples
                      represented by columns and rows, respectively. The samples charactersitcs are also indicated on the right hand-side. Only the 200 genes
                      with the highest expression variance across samples are presented.
                    </p>
                  </div>";

                  chdir($result_directory);
                  $heatmap_files = glob("heatmap_exp_1*.html");
                  if (count($heatmap_files) > 0) {
                    foreach ($heatmap_files as &$heatmap_files) {
                      echo "<div class='pca_container'>
                              <iframe class='results' scrolling='no' src='$iframe_directory/$heatmap_files'></iframe>
                            </div>";
                    }
                  } else {
                     echo "<h3> Sorry no analyses are available </h3>";
                  }

          echo "</div>";
        }
        elseif ($pa == "Expression profiles") {
          echo "<div id='$pa_web$cont' >
                  <div class='description'>
                    <p class='pub_det'>
                      The expression profile of selected gene(s) across comparative groups are presented as both summarised and a
                      sample views (boxplots and barplots, respectively).
                    </p>
                    <br><br>
                    <h4> Please select a gene of interest </h4>
                    <br>
                    <u class=\"note\"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                    <br><br>
                  </div>";

          // loading autocomplete text
          echo "<select id=\"ep$cont\"></select>
                <button id=\"runep$cont\" class=\"run\"> Run analysis </button>";

          echo "<div class='gea' id='gea'></div>";

          // loading graph container when result launched
          echo "<div class='expression_profile_container' id='GraphContainerEP_$pa_web'></div>";
          echo "<iframe class='results' id='ep$cont"."_box'></iframe>";
          echo "<iframe class='results' id='ep$cont"."_bar'></iframe>";

          // loading javascripts
          echo "<script>LoadGeneSelector(\"ep$cont\",\"$ae\",\"$pmid\", \"\")</script>";
          echo "<script>LoadAnalysis(\"ep$cont\",\"runep$cont\",\"$ae\",\"$pmid\",\"gene_expression\",\"$cont\")</script>";

        echo "</div>";
      }
      elseif ($pa == "Expression correlations") {
          echo "<div id='$pa_web$cont'>
                  <div class='description'>
                    <p class='pub_det'>
                      We offer users the opportunity to identify genes that are co-expressed with their gene(s) of interest.
                      This value is calculated using the Pearson Product Moment Correlation Coefficient (PMCC) value.
                      Correlations for the genes specified by the user are presented in a heatmap.
                    </p>
                    <br><br>
                    <h4> Please select at least 2 genes of interest (max 50 genes)</h4>
                    <br>
                    <u class=\"note\"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                    <br><br>
                    <select multiple id=\"cea$cont\"></select>
                    <br><br><br>
                    <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
                    <br><br>
                    <textarea id=\"textcea$cont\" rows=\"3\" cols=\"80\"></textarea>
                    <br>
                    <button id=\"runcea$cont\" class=\"run\"> Run analysis </button>
                  </div>";

            echo "<div class='cea' id='cea'></div>";

            // loading graph container when result launched
            echo "<div class='coexpression_container' id='GraphContainerCEA_$pa_web'></div>";
            echo "<iframe class='results' id='cea$cont"."_hm'></iframe>";

            // loading javascripts
            // NB: Rplots start counting from 1 -- adding 1 to php $cont
            echo "<script>LoadGeneSelector(\"cea$cont\",\"$ae\",\"$pmid\", \"\")</script>";
            echo "<script>LoadAnalysis(\"cea$cont\",\"runcea$cont\",\"$ae\",\"$pmid\",\"co_expression\",\"$cont\")</script>";

          echo "</div>";

        }
        elseif ($pa == "Gene networks") {
            echo "<div id='$pa_web$cont'>
                    <div class='description'>
                      <p class='pub_det'>
                        Here we present an interactive tool to explore interactions among genes' products of interest.
                      </p>
                      <br><br>
                      <table id=\"network_parameters_container\">
                        <tr style=\"height:70px; vertical-align:top\">
                          <td colspan=2>
                            <h4> Please select the genes of interest </h4>
                            <br>
                            <u class=\"note\"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                            <br><br>
                            <select multiple id=\"net$cont\"></select>
                            <br><br>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <h4> Please select the interaction score threshold </h4>
                            <br><br>
                            <div id=\"mentha-score\"></div>
                            <!-- loading threshold labels -->
                            <input type=\"text\" id=\"min_thr_label\" readonly>
                            <input type=\"text\" id=\"max_thr_label\" readonly>
                          </td>
                          <td>
                            <button id=\"runnet$cont\" class=\"run\"> Run analysis </button>
                          </td>
                        </tr>
                      </table>
                      <!-- load legend div -->
                      <div id='net_legend' title='Network legend' style='display:none'>
                        <img src='../images/net_legend.svg'
                      </div>
                    </div>";

              echo "<div class=\"net\" id=\"net\"></div>";

              // loading graph container when result launched
              echo "<div class='network_container' id='GraphContainerNET_$pa_web'>";
                // initializing hidden value for random code (useful for changing graph later)
                echo "<input type=\"hidden\" id=\"random_code\"/>";
                echo "  <table>
                          <tr>
                            <h4> Speciments available in the dataset: </h4><br>";

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


                echo "    </tr>
                        </table>";

                // inserting legend for color nodes
                echo "<br><br>
                      <img src='../images/question_mark.png' onClick='LoadLegend()' style='width:30px; height:30px'/>";

                echo "<iframe class='results' id='network_container' onload='resizeIframe(this);'></iframe>";

                // loading table with interactions
                echo "<table id='network_details' class='table table-bordered results' cellspacing='0' width='100%'>
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
                      </table>";

              echo "</div>";

              // loading javascripts
              echo "<script>LoadScoreSlider(\"mentha-score\")</script>";
              echo "<script>LoadGeneSelector(\"net$cont\",\"$ae\",\"$pmid\", \"\")</script>";
              echo "<script>LoadAnalysis(\"net$cont\",\"runnet$cont\",\"$ae\",\"$pmid\",\"gene_network\",\"0\")</script>";

            echo "</div>
                </div>";
          }
          elseif ($pa == "Survival analysis") {
          echo "<div id='$pa_web$cont'>
                  <div class='description'>
                    <p class='pub_det'>
                      The relationship between gene of interest and survival can be assessed.
                      A univariate model is applied to the survival data and samples are assigned to risk groups
                      based on the median dichotomisation of mRNA expression intensities of the selected gene.
                      Relationships are presented as Kaplan-Meier plots.
                    </p>
                      <br><br>
                      <h4> Please select a gene of interest </h4>
                      <br>
                      <u class=\"note\"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                      <br><br>
                  </div>";

                  // loading autocomplete text
                  echo "<select id=\"surv$cont\"></select>
                        <button id=\"runsurv$cont\" class=\"run\"> Run analysis </button>";

                  echo "<div class='surv' id='surv'></div>";

                  // loading graph container when result launched
                  echo "<div class='survival_container' id='GraphContainerSURV_$pa_web'></div>";

                  //  echo "<center>
                  //          <img src='$iframe_directory/KM_subtype.png'>
                  //        </center>";
                  echo "<center>
                        <iframe class='results' id='surv$cont"."_km'></iframe>
                        </center>";

                  // loading javascripts
                  // NB: Rplots start counting from 1 -- adding 1 to php $cont
                  $plot_cont = $cont + 1;
                  echo "<script>LoadGeneSelector(\"surv$cont\",\"$ae\",\"$pmid\", \"\")</script>";
                  echo "<script>LoadAnalysis(\"surv$cont\",\"runsurv$cont\",\"$ae\",\"$pmid\",\"survival\",\"$plot_cont\")</script>";

        echo "</div>";
        }
      }
      // Loading Javascript Functions
      echo "<script>LoadResultTabs($cont)</script>";
      $cont++;
echo "</div>
    </div>";
  }
echo "
  </div>
</div> ";
echo "<script>LoadResultAcc()</script>";

?>
