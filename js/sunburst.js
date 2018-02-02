// Javascript method for sunburst Statistics

function LoadStatisticsSunburst(type) {

  $("div#statistics").empty();

  var width = 960,
    height = 800,
    radius = Math.min(width, height) / 2.1;

  var x = d3.scale.linear()
      .range([0, 2 * Math.PI]);

  var y = d3.scale.linear()
      .range([0, radius]);

  var color = d3.scale.category20c();

  var svg = d3.select("div#statistics").append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")
      .attr("transform", "translate(" + width / 2 + "," + (height / 2 + 10) + ")");

  var partition = d3.layout.partition()
      .sort(null)
      .value(function(d) {
        if (d.size < 300) {
          return d.size+300;
        } else {
          return d.size;
        }
      });

  var arc = d3.svg.arc()
      .startAngle(function(d) {
        return Math.max(0, Math.min(2 * Math.PI, x(d.x)));})
      .endAngle(function(d) {
        return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx)));})
      .innerRadius(function(d) { return Math.max(0, y(d.y)); })
      .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

  // tooltip
  var tooltip = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

  d3.json("../js/statistics_jsons/data_type_statistics.json", function(error, root) {
    var g = svg.selectAll("g")
        .data(partition.nodes(root))
      .enter().append("g");

    var path = g.append("path")
      .attr("d", arc)
      .style("fill", function(d) {
        return color(d.value); // coloring according to the value
      })//{ return color((d.children ? d : d.parent).name); })
      .style("stroke", "white")
      .style("stroke-width", "1px")
      .on("click", click)
      .on("click", click)
      .on("mouseover", function(d, i) {
        d3.select(this).style("cursor", "pointer")
        var totalSize = path.node().__data__.value;
        //var percentage = Math.round(((100 * d.value / totalSize) * 100) / percentBase);
        var percentageString = d.real_number + "";

        //if (d.name == "Sources") return null;
        tooltip.text(d.name + " " + percentageString)
          .style("opacity", 0.8)
          .style("left", (d3.event.pageX) + 0 + "px")
          .style("top", (d3.event.pageY) - 0 + "px");
        //if (d.name == "Sources") {
        //  return null;
        //}
      })
      .on("mouseout", function(d) {
        d3.select(this).style("cursor", "default")
        tooltip.style("opacity", 0);
      });

    var text = g.append("text")
      .attr("transform", function(d) {
        return "translate(" + arc.centroid(d) + ")rotate(" + computeTextRotation(d) + ")";
      })
      //.attr("x", function(d) { return y(d.y); })
      .attr("text-anchor", "middle")
      .attr("dx", "0") // margin
      .attr("dy", ".35em") // vertical-align
      .text(function(d) {
        return d.name == "The Cancer Genome Atlas" ? "TCGA" :
              d.name == "Copy Number Variation" ? "CNV" :
              d.name == "Cancer Cell Line Encyclopedia" ? "CCLE" :
              d.name == "gene expression" ? "expression" :
              d.name == "Home" ? "Reset" : d.name;
      })
      .style("font-size", "15px")
      .style("font-family", "Helvetica Neue")
      .style("fill", "#0a2538");

    function click(d) {
      // fade out all text elements
      text.transition().attr("opacity", 0);

      path.transition()
        .duration(750)
        .attrTween("d", arcTween(d))
        .each("end", function(e, i) {
            // check if the animated element's data e lies within the visible angle span given in d
            if (e.x >= d.x && e.x < (d.x + d.dx)) {
              // get a selection of the associated text element
              var arcText = d3.select(this.parentNode).select("text");
              // fade in the text element and recalculate positions
              arcText.transition().duration(750)
                .attr("opacity", 1)
                .attr("transform", function(d) {
                  return "translate(" + arc.centroid(d) + ")rotate(" + computeTextRotation(d) + ")";
                })
                .attr("text-anchor", "middle");
            }
        });
    }
  });

  d3.select(self.frameElement).style("height", height + "px");

  // Interpolate the scales!
  function arcTween(d) {
    var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
        yd = d3.interpolate(y.domain(), [d.y, 1]),
        yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
    return function(d, i) {
      return i
          ? function(t) { return arc(d); }
          : function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
    };
  }

  function computeTextRotation(d) {
    var ang = (x(d.x + d.dx / 2) - Math.PI / 2) / Math.PI * 180;
    return (ang > 90) ? 180 + ang : ang;
  }
}
