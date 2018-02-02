/* Javascript methods for the Tissue Finder 2.0 *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: all the javascript behaviours of the BOB portal, are included here. */

// loading frame
var loading = "<center><h2>Loading results, please wait...</h2><img src='../images/loading.svg' alt='Loading'></center>";

// webiste for loading iframe
var iframe_url = "../../PIXdb/pixdb_backoffice/tmp/";


function LoadHomePage() {
  $("#source.container").load("home.php");
  $("#source.container").show();
  //console.log("LoadHomePage");
}

function LoadSelector() {
	$(".analysis_sel").button();
    $(".analysis_sel").click(function() {
        var clickedId = $(this).attr("id");
        //$("#main.container").hide();
        //$("#main.container").empty(); // emptying all the items inside the div
        $("#results.container").empty(); // emptying all the items inside the div
        $("#main.container").load(""+clickedId+".php", function(){
          $("#description.container").hide("slow");
          $("#main.container").show();
        });
    });
}

function LoadPlatformsSelector() {
	$(".analysis_sel").button();
    $(".analysis_sel").click(function() {
        var clickedId = $(this).attr("id");
        //$("#main.container").hide();
        $("#main.container").empty(); // emptying all the items inside the div
        $("#results.container").empty(); // emptying all the items inside the div
        $("#main.container").load(""+clickedId+".php", function(){
          $("#description.container").hide("slow");
          $("#main.container").show();
        });
    });
}

function LoadMenuSelector() {
  $("a.menu_btn").click(function(event) {
    $("#source.container").hide();
    var clickedId = $(this).attr("id");
    var text = $("#source.container").load(""+clickedId+".php");
    $("#source.container").html();
    $("#source.container").show();
    event.preventDefault();
  });
}

function LoadDatasetsTable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var papersTable = $('#papers').DataTable( {
      dom: 'Bfrtip',
      buttons: [
            'copyHtml5',
            'excelHtml5',
            'csvHtml5',
            'pdfHtml5'
      ],
			"order": [[ 4, "desc" ]],
			"processing": false,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_datasets.php",
				"type":"post"
			},
			"columnDefs": [
            {
                "targets": [ 5 ],
                "visible": false
            },
			]
		});

    yadcf.init(papersTable, [{
      column_number: 4,
      filter_type: "range_date",
      date_format: "yy-mm-dd",
      filter_container_id: "pubdate_filter",
      filter_plugin_options: {
        changeMonth: true,
        changeYear: true
      }
    },
    {
      column_number: 5,
      filter_type: 'multi_select_custom_func',
      custom_func: cumulative,
      select_type: 'chosen',
      text_data_delimiter: ',',
      filter_container_id: 'bioinfo_filter',
    }]);

	// highlight selected rows
	$('#papers tbody').on( 'click', 'tr', function () {
		$("#analysis_button").show();
		if ( $(this).hasClass('selected') ) {
				$(this).removeClass('selected');
		}
		else {
				papersTable.$('tr.selected').removeClass('selected');
				$(this).addClass('selected');
		}
	});

    $("#run").button();
			$("#run").click(function(e) {
        var PMID = $('table#papers tr.selected').children().eq(2).text();
        $("#results.container").load("scripts/loading_results_datasets.php?pmid="+PMID+"");
        $("#results.container").show();
		});

		$("#filter").accordion({
			 heightStyle: "content",
			 multiple: true,
			 collapsible: true
		});
}

function LoadPlatformsTable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var platformsTable = $('table#platforms').DataTable( {
			"order": [[ 4, "desc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_platforms.php",
				"type":"post"
			}
		});
}

function LoadCrossPlatformTable() {

		// hiding results frame
		$("#analysis_container").hide();
		// hiding analysis_button
		$("#analysis_button").hide();

		// INITIALISING DATA TABLE //
		var crossplatformTable = $('table#crossplatform').DataTable( {
			"order": [[ 1, "asc" ]],
			"processing": true,
			"serverSide": false,
			"ajax": {
				"url":"scripts/server_processing_crossplatform.php",
				"type":"post"
			}
		});
}

// function to Load Tabs
function LoadResultTabs(cont) {
  $("#tabs_s"+cont+"").tabs();
}

function LoadPlatformsTabs() {
  $("#platforms_results.container").tabs();
}

function LoadCrossPlatformTabs() {
  $("#crossplatform_results.container").tabs();
}

// function to load MultiGeneSelector
// this function takes as input the name of html element to call,
// the array express id and PMID id (to call the right expression matrix)
function LoadGeneSelector(el_name, ae, pmid, type_analysis) {

  $.fn.select2.defaults.set("theme", "classic");
  $.fn.select2.defaults.set("ajax--cache", false);

  // we decided to implement an ajax-based search
  $( "#"+el_name+"" ).select2({
    width:'50%',
    //maximumSelectionSize: 50,
    ajax: {
      url: "scripts/RetrieveGeneList.php?ae="+ae+"&pmid="+pmid+"&type_analysis="+type_analysis+"",
      dataType: "json",
      delay: 250,
      data: function (params) {
				if (params.term === undefined) {
					//console.log("null");
					return {
						q: "A", // search term
					};
				} else {
					//console.log("not null");
					//console.log(params.term);
					return {
						q: params.term, // search term
					};
				}
      },
      processResults: function (data, params) {
				console.log(data);
        return {
          results: data
        };
        var q = '';
      },
      cache: false
    }
  });
}

function LoadGroupSelector(el_name) {

  $( "."+el_name+"" ).selectmenu();
}
// function to load CCLE cell lines
// this function takes as input the name of html element to call
function LoadCLSelector(el_name, type_analysis) {

  $.fn.select2.defaults.set("theme", "classic");
  $.fn.select2.defaults.set("ajax--cache", false);

  // we decided to implement an ajax-based search
  $( "#"+el_name+"" ).select2({
    width:'50%',
    //maximumSelectionSize: 50,
    ajax: {
      url: "scripts/RetrieveCLList.php",
      dataType: "json",
      delay: 250,
      data: function (params) {
        return {
          q: params.term, // search term
        };
      },
      processResults: function (data, params) {
        return {
          results: data
        };
        var q = '';
      },
      cache: false
    }
  });
}
// this function launch the Rscript to create the expression profile plot for the selected gene
// the function takes three parameter
// -- el_name: html element to call
// -- ae: array_express id
// -- pmid : pubmed id
// Please note, for security reasons, the launch of Rscript and all system commands are delegated to
// a php function ("LaunchCommand.php")
function LoadAnalysis(genebox, el_name, ae, pmid, type_analysis, cont) {
  var random_code = Math.random().toString(36).substring(7);
  if (type_analysis == "gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea").html(loading);
            $("#gea").show();
          },
          success: function(data) {
            $("#gea").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false;
      }
    });
  }
  else if (type_analysis == "co_expression") {
    $("#"+el_name+"").click(function() {
      // loading single genes selector
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array);

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea").html(loading);
            $("#cea").show();
          },
          success: function(data) {
            $("#cea").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "survival") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#surv").html(loading);
            $("#surv").show();
          },
          success: function(data) {
            $("#surv").hide();
            // remove all the images inside the div
            $('div.survival_container').remove();
            // append the new images
            // $(".survival_container").html("<center><img src='"+iframe_url+random_code+"_KMplot.png'></center>");
            // $(".survival_container").append("<center><img src='"+iframe_url+random_code+"_KMplot.png'></center>");
            $("iframe#"+genebox+"_km.results").attr("src", ""+iframe_url+random_code+"_KMplot.png");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&ArrayExpressCode="+ae+"&PMID="+pmid+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#net").html(loading);
              $("#net").show();
            },
            success: function(data) {
              $("#net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
  }

	else if (type_analysis == "RNA_seq_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea_platforms").html(loading);
            $("#gea_platforms").show();
          },
          success: function(data) {
            $("#gea_platforms").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "RNA_seq_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array)

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea_platforms").html(loading);
            $("#cea_platforms").show();
          },
          success: function(data) {
            $("#cea_platforms").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea_platforms").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "RNA_seq_gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#platforms_net").html(loading);
              $("#platforms_net").show();
            },
            success: function(data) {
              $("#platforms_net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#platformsa_net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
	}

	else if (type_analysis == "Affy_HuEx1ST_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea_platforms").html(loading);
            $("#gea_platforms").show();
          },
          success: function(data) {
            $("#gea_platforms").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_HuEx1ST_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array)

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea_platforms").html(loading);
            $("#cea_platforms").show();
          },
          success: function(data) {
            $("#cea_platforms").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea_platforms").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_HuEx1ST_gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#platforms_net").html(loading);
              $("#platforms_net").show();
            },
            success: function(data) {
              $("#platforms_net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#platformsa_net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
	}

	else if (type_analysis == "Affy_U133Plus2_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea_platforms").html(loading);
            $("#gea_platforms").show();
          },
          success: function(data) {
            $("#gea_platforms").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U133Plus2_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array)

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea_platforms").html(loading);
            $("#cea_platforms").show();
          },
          success: function(data) {
            $("#cea_platforms").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea_platforms").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U133Plus2_gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#platforms_net").html(loading);
              $("#platforms_net").show();
            },
            success: function(data) {
              $("#platforms_net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#platformsa_net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
	}

	else if (type_analysis == "Affy_U133A_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea_platforms").html(loading);
            $("#gea_platforms").show();
          },
          success: function(data) {
            $("#gea_platforms").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U133A_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array)

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea_platforms").html(loading);
            $("#cea_platforms").show();
          },
          success: function(data) {
            $("#cea_platforms").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea_platforms").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U133A_gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#platforms_net").html(loading);
              $("#platforms_net").show();
            },
            success: function(data) {
              $("#platforms_net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#platformsa_net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
	}

	else if (type_analysis == "Affy_U95Av2_gene_expression") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#gea_platforms").html(loading);
            $("#gea_platforms").show();
          },
          success: function(data) {
            $("#gea_platforms").hide();
            $("iframe#"+genebox+"_box.results").attr("src", ""+iframe_url+random_code+"_box.html");
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U95Av2_co_expression") {
    $("#"+el_name+"").click(function() {
      var genes_sel = $("#"+genebox+"").val();

      // loading text area (gene list selector)
      var genes_list = $("#text"+genebox+"").val().toUpperCase();
      // splitting genes list by wide space chars
      var genes_list_array = genes_list.split(/\s+/);

      // pushing gene list into the genes array
      var genes = genes_sel.concat(genes_list_array)

      // checking the length of the uploaded genes
      if (genes.length >= 2 && genes.length <= 50) {
        var genes_string = genes.join(",");

        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes_string+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#cea_platforms").html(loading);
            $("#cea_platforms").show();
          },
          success: function(data) {
            $("#cea_platforms").hide();
            $("iframe#"+genebox+"_hm.results").attr("src", ""+iframe_url+random_code+"_corr_heatmap.html");
            $("iframe.results").show();
          },
          error: function(data) {
            alert("Sorry, there is an error in the analysis...\n\
                  Probably the number of genes submitted to the analysis is less then 2.");
            $("#cea_platforms").hide();
          }
        });
      } else {
        alert("Please select at least 2 genes (max 50)");
        return false
      }
    });
  }
  else if (type_analysis == "Affy_U95Av2_gene_network") {
    $("#"+el_name+"").click(function() {
      // getting genes of interest
      var genes = $("#"+genebox+"").val();

      // getting min and max score thresolds
      var min_thr = $("input#min_thr_label").val();
      var max_thr = $("input#max_thr_label").val();

      // checking the length of the uploaded genes
        if (genes.length >= 1 && genes.length < 6) {
          // launching ajax call to retrieve the expression plot for the selected gene
          $.ajax( {
            url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+genes+"&rc="+random_code+"&min_thr="+min_thr+"&max_thr="+max_thr+"",
            type:"get",
            beforeSend: function()
            {
              $("#platforms_net").html(loading);
              $("#platforms_net").show();
            },
            success: function(data) {
              $("#platforms_net").hide();
              $("input#random_code").val(random_code);
              $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+cont+".html");
              $("iframe.results").show();
              var table = $('table#network_details').DataTable( {
                dom: 'Bfrtip',
                buttons: [
                      'copyHtml5',
                      'excelHtml5',
                      'csvHtml5',
                      'pdfHtml5'
                ],
                "processing": false,
                "serverSide": false,
                "destroy": true,
                "ajax": {
                  "url": ""+iframe_url+random_code+"_network0.json", // we visualize the first network as default
                }
              });
              $(".network_container").show();
              $("#platformsa_net").hide();
            }
          });
        } else {
          alert("Please select a minimum of 1 and maximum number of 5 genes");
          return false
        }
    });
	}

	else if (type_analysis == "crossplatform_volcano") {
    $("."+el_name+"").click(function() {
      var cl = $(this).val();
      var file = "../pixdb_backoffice/data/crossplatform/"+cl+"_volcano.html";
      $("#volcano_crossplatform").hide();
      $(".loading").hide();
      $("iframe#"+el_name+"_box.results").attr("src", file);
      $("iframe.results").show();
    });
  }
  else if (type_analysis == "stats_crossplatform") {
    $("#"+el_name+"").click(function() {
      var gene = $("#"+genebox+"").val();

      // checking the length of the uploaded genes
      if (gene.length = 1) {
        // launching ajax call to retrieve the expression plot for the selected gene
        $.ajax( {
          url:"scripts/LaunchCommand.php?TypeAnalysis="+type_analysis+"&Genes="+gene+"&rc="+random_code+"",
          type:"get",
          beforeSend: function()
          {
            $("#stats_crossplatform").html(loading);
            $("#stats_crossplatform").show();
          },
          success: function(data) {
            $("#stats_crossplatform").hide();
            $("iframe#"+genebox+"_bar.results").attr("src", ""+iframe_url+random_code+"_bar.html");
            $("iframe.results").show();
          }
        });
      } else {
        alert("Please select at least 1 genes");
        return false
      }
    });
  }
}
// this function load the Tumor purity data table to visualise samples and
// giving the possibility to filter according to the tumor purity Estimate score
function LoadDetailDataTable(el_name, type) {
  if (type == "Estimate") {
    var EstimateTable = $("#"+el_name+"").DataTable({
      dom: 'Bfrtip',
      buttons: [
            'copyHtml5',
            'excelHtml5',
            'csvHtml5',
            'pdfHtml5'
      ]
    });
    yadcf.init(EstimateTable, [{
      column_number: 2,
      filter_type: "range_number_slider",
    }]);
  } else {
    $("#"+el_name+"").DataTable({
        dom: 'Bfrtip',
        buttons: [
              'copyHtml5',
              'excelHtml5',
              'csvHtml5',
              'pdfHtml5'
        ]
    });
  }
}

// Function for cumulative_filtering in analysis
function cumulative(filterVal, columnVal) {
	if (filterVal === null) {
  	return true;
  }
	if (filterVal){
		var found;
		var myElement;
		var foundTout = 0;
		var nbElemSelected = filterVal.length;

      for (i=0; i<nbElemSelected; i++)
      {
          myElement = filterVal[i];
          switch (myElement) {
            case "Expression profiles":found = columnVal.search(/Expression profiles/g);
            break;
            case "Expression correlations":found = columnVal.search(/Expression correlations/g);
            break;
            case "PCA":found = columnVal.search(/PCA/g);
            break;
            case "Expression heatmap":found = columnVal.search(/Expression heatmap/g);
            break;
						case "Survival analysis":found = columnVal.search(/Survival analysis/g);
            break;
            case "Tumour purity":found = columnVal.search(/Tumour purity/g);
            break;
            case "Gene networks":found = columnVal.search(/Gene networks/g);
            break;
          } //close switch
          if (found !== -1) {foundTout++;}
      } // close for
      if (foundTout == filterVal.length) {return true;}
      else {return false;}
	} //close if(filterVal)
} //close myCustomFilterFunction()

// function for scrolling page into specific div
function ascrollto(id) {
	var etop = ($(id).offset().top)+2000;
	$(document).animate({
	  scrollTop: etop+500
	}, 1000);
}

// function for loading the documentation accordion
function LoadDocAcc() {
  $("#doc_acc").accordion({
    heightStyle: "content"
  });
}

// function for loading the results accordion
function LoadResultAcc() {
  $("#res_acc").accordion({
    heightStyle: "content",
    active: false,
    collapsible: true
  });
}

function LoadNetworkGraph(index) {
  var random_code = $("input#random_code").val();
  $("iframe#network_container.results").attr("src", ""+iframe_url+random_code+"_network"+index+".html");
  $('table#network_details').DataTable().ajax.url(""+iframe_url+random_code+"_network"+index+".json").load();
}

function LoadLegend() {
  $( "#net_legend" ).dialog();
    $( "#net_legend" ).show();
}

function LoadScoreSlider(el_name) {
  $( "div#"+el_name+"" ).slider({
      range: true,
      step: 0.1,
      min: 0,
      max: 1,
      values: [ 0.4, 0.8],
      slide: function( event, ui ) {
        $( "#min_thr_label" ).val( "" + ui.values[ 0 ] + "");
        $( "#max_thr_label" ).val( "" + ui.values[ 1 ] + "");
      }
  });
  // initilizing values on load
  $( "#min_thr_label" ).val(""+$("div#"+el_name+"").slider("values",0)+"");
  $( "#max_thr_label" ).val(""+$("div#"+el_name+"").slider("values",1)+"");
}

// function to adjust the size of the results iframe according to the content
// function to adjust the size of the results iframe according to the content
function resizeIframe(obj){
  obj.style.height = 0;
  obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
}
