<?php

echo <<< EOT
<div>
    <p>
      Welcome to <b>Prostate Integrative Expression Database</b> (PIXdb), a repository for mining, integrating and analysing prostate-related transcriptomics data.
    </p>
    <center>
      <table>
        <tr style='text-align:center'>
          <td>
            <h3> Select the starting poing for analysis </h3>
          </td>
        </tr>
        <tr>
            <td>
                <button class="analysis_sel" id="Datasets"> Per-dataset </button>
                <button class="analysis_sel" id="Platforms"> Per-platform </button>
                <button class="analysis_sel" id="CrossPlatform"> Cross-platform </button>
            </td>
        </tr>
      </table>
    </center>
</div>
<br><br>

<div class="container" id="description">
  <table id="sel_container">
      <tr>
          The data sources accessed by PIXdb are datasets publicly-available in <a href="https://www.ebi.ac.uk/arrayexpress/" target="_blank">ArrayExpress</a>, <a href="https://www.ncbi.nlm.nih.gov/geo/" target="_blank">Gene Expression
  Omnibus</a> (GEO), <a href="https://www.ncbi.nlm.nih.gov/sra" target="_blank">Sequence Read Archive</a> (SRA), <a href="https://cancergenome.nih.gov/" target="_blank">The Cancer Genome Atlas</a> (TCGA)
  and <a href="http://icgc.org/" target="_blank">International Cancer Genome Consortium</a> (ICGC). PIXdb provides you with the means to conduct exploratory
  and in-depth analyses of prostate-related transcriptomic data.<br><br>
          <b>Per-dataset:</b> From this tab, you will be able to conduct multiple analyses, including principal component analysis (PCA), estimates
          of tumour purity, expression heatmap, gene expression and expression correlation plots, survival analyses and gene networks, using gene expression data from individual datasets.<br><br>
          <b>Per-platform:</b> This tab allows you to perform analyses using integrated expression data from the same platform. Availabe analyses include
          PCA, estimates of tumour purity, expression heatmap, gene expression and expression correlation plots, as well as investigate gene networks.<br><br>
          <b>Cross-platform:</b> This tab contains results from the largest multi-cohort study of prostate cancer mRNA profiles to date. Using data derived from a
          combination of RNA-seq and microarray platforms, we applied our <a href="https://github.research.its.qmul.ac.uk/hfw456/transcriptomics_data_integration" target="_blank">cross-platform data integration pipeline</a>
          to an extensive set of prostate-related gene expression profiles, including <i>healthy</i>, <i>HGPIN</i> and <i>primary tumour</i> tissues, as well as
          <i>prostate cancer with metastasis</i> and <i>multi-site metastatic prostate cancer</i> tissues, to reveal <i><b>transcriptomics landscape of prostate cancer</b></i>.
          Here, you can find a summary table with gene ranks indicating individual gene's evidence for aberrant expression in various biological comparisons.
          You can also explore the results for each biological comparison using volvano plots, as well as query
          these statistics for individual genes. A detailed description of the integrative analysis pipeline is described in
          <a href="https://github.research.its.qmul.ac.uk/hfw456/transcriptomics_data_integration" target="_blank">GitHub repository</a>.<br><br>
        In total, 1,488 transcriptomic profiles from 472 normal (83 healthy or benign prostate enlargement (BPH) and 389 normal adjacent) prostate tissues,
        33 high-grade prostatic intraepithelial neoplasia (HGPIN) samples, 880 samples from primary prostate cancer patients without metastasis (primary tumour),
        31 samples from primary prostate cancer with metastasis (metastatic primary tumour) and 72 samples from metastatic prostate cancer tissues (metastasis)
        are available for ealuation of aberrantly expressed genes associated with prostate cancer initiation, development and progression to aggressive disease.
      </tr>
      <!-- Space for some data stats -->
      <!--
      <tr>
        <td><iframe class="home_stats" scrolling='no' src='stat.html'></iframe></td>
        <td><iframe class="home_stats" scrolling='no' src='stat_analysis.html'></iframe></td>
      </tr>
      -->
  </table>
</div>
<br>

<div class="container" id="main"></div>
<div class="container" id="loading"></div>
<div class="container" id="results"></div>

<!-- Sunburst graph
<div class="container" id="description">
  <center><h4> Statistics </h4></center>
  <div class="container" id="statistics"></div>
</div>
-->

<!-- Prostate cancer data summary -->
<div class="container" id="description">
  <center><h4> Data summary </h4></center>
  <br>
  <center>
    <tr>
        <td><a href="index.php"><img class="menu_sel" src="../images/data_summary.png" style="width:70%"/></a></td>
    </tr>
  </center>
</div>
<br><br>

<div class="container" id="description">
  <table id="sel_container">
      <tr>
          <i>Normal prostate</i> - tissue from healthy prostate or benign prostate hyperplasia (BPH)<br>
          <i>Normal adjacent</i> - normal prostate tissue adjacent to tumour<br>
          <i>HGPIN</i> - high-grade prostatic intraepithelial neoplasia<br>
          <i>Primary tumour</i> - primary tumour from prostate<br>
          <i>Metastatic primary tumour</i> - samples from primary tumour derived from prostate cancer patients with metastasis<br>
          <i>Metastasis</i> - samples from metastatic prostate cancer tissues<br>
      </tr>
  </table>
</div>

<br>
<script> LoadSelector() </script>

<!-- Sunburst graph
<script> LoadStatisticsSunburst("data_type") </script>
-->

EOT;



?>
