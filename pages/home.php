<?php

echo <<< EOT
<div>
    <p>
      Welcome to the <b>Prostate Integrative Expression Database</b> (PIXdb), a repository for mining, integrating and analysing prostate-related transcriptomics data.
    </p>
    <center>
      <table>
        <tr style='text-align:center'>
          <td>
            <h3> Select the starting point for analysis </h3>
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
          PIXdb contains gene expression data from <a href="https://www.ebi.ac.uk/arrayexpress/" target="_blank">ArrayExpress</a>, <a href="https://www.ncbi.nlm.nih.gov/geo/" target="_blank">Gene Expression
  Omnibus</a>, <a href="https://www.ncbi.nlm.nih.gov/sra" target="_blank">Sequence Read Archive</a>, <a href="https://cancergenome.nih.gov/" target="_blank">The Cancer Genome Atlas</a> (TCGA)
  and <a href="http://icgc.org/" target="_blank">International Cancer Genome Consortium</a> (ICGC), and provides you with the means to conduct exploratory
  and in-depth analyses of these datasets in isolation or as an integrated dataset with the option of tracking molecular events across different stages of prostate cancer development and progression.<br><br>
          <b>Per-dataset:</b> From this tab, you can conduct multiple analyses, including principal component analysis (PCA), estimates
          of tumour purity, heatmap, expression profile and correlation plots, survival analyses and gene networks, using gene expression data from individual datasets.<br>
          <i>Data available from figshare <b><a href="https://doi.org/10.6084/m9.figshare.c.5347085.v1" target="_blank">datasets collection</a></b></i>.<br><br>
          <b>Per-platform:</b> This tab allows you to perform analyses using combined expression data from the same platform. Available analyses include
          PCA, estimates of tumour purity, heatmap, expression profile and correlation plots, as well as investigate gene networks.<br>
          <i>Data available from figshare <b><a href="https://doi.org/10.6084/m9.figshare.c.5655955.v1" target="_blank">platforms collection</a></b></i>.<br><br>
          <b>Cross-platform:</b> This tab contains results from our <a href="https://pages.github.research.its.qmul.ac.uk/hfw456/transcriptomics_data_integration" target="_blank">cross-platform integrative analysis</a>
          of prostate cancer mRNA profiles from <i>normal prostate</i>, <i>high-grade prostatic intraepithelial neoplasia (HGPIN)</i>, <i>primary prostate cancers</i> from patients <i>with</i> and <i>without metastasis</i>, and <i>metastatic prostate cancer</i> tissues,
          to reveal the <b><a href="https://pubmed.ncbi.nlm.nih.gov/33477882/" target="_blank">transcriptomics landscape</a></b> of this disease (<a href="https://pubmed.ncbi.nlm.nih.gov/33477882/" target="_blank">Marzec et al., 2021</a>).
          Here you can explore the results for each biological comparison using volcano plot and heatmap, as well as query
          gene ranks and associated statistics for individual genes.<br>
          <i>Data available from figshare <b><a href="https://doi.org/10.6084/m9.figshare.c.5656135.v1" target="_blank">cross-platform collection</a></b></i>.<br><br>
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
  <center><h4> Prostate cancer transcriptomics landscape</h4></center>
  <br>
  <center>
    <tr>
        <td><a href="index.php"><img class="menu_sel" src="../images/bio_comp_home.png" style="width:70%"/></a></td>
    </tr>
  </center>
</div>
<br><br>

<div class="container" id="description">
  <table id="sel_container">
      <tr>
        In total, 1,488 transcriptomic profiles from 472 normal (83 healthy or benign prostate enlargement (BPH) and 389 normal adjacent) prostate tissues,
        33 HGPIN samples, 880 samples from primary prostate cancer patients without metastasis (primary tumour),
        31 samples from primary prostate cancer with metastasis (metastatic primary tumour) and 72 samples from metastatic prostate cancer tissues (metastasis)
        are available for evaluation of aberrantly expressed genes associated with prostate cancer initiation, development and progression to aggressive disease.
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
          <i>Metastasis</i> - samples from metastatic prostate cancer tissues<br><br>
          <i>*</i> gene expression profiles produced with RNA-seq platforms<br>
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
