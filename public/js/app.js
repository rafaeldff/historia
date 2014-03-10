function addToList(commits) {
    var list = $(".commits");
    $(commits).each(function (i, commit) {
      list.append("<li>"+commit["oid"]+": "+commit["message"]+"</li>");
    });
}

function addCommitNodes(g, commits) {
    $(commits).each(function (i, commit) {
      var oid = commit["oid"];
      if (! g.hasNode(oid)) {
        g.addNode(oid, {label: commit["message"]});
      }
    });
}

function addEdges(g, commits) {
  $(commits).each(function (i, commit) {
    var oid = commit["oid"];
    $(commit["parents"]).each(function(i, parent_oid) {
      g.addEdge(null, oid, parent_oid, {});
    });
  });
}

function draw(g) {
  var layout = dagreD3.layout().nodeSep(40).rankDir("LR");
  var renderer = new dagreD3.Renderer();
  var svg = d3.select("svg");
  var svgg = svg.select("g");

  var rendered = renderer.layout(layout).run(g, svgg);
  var zoom = d3.behavior.zoom()
    .on("zoom",function() {
      svgg.attr("transform","translate("+ 
        d3.event.translate.join(",")+")scale("+d3.event.scale+")");
    });
  svg.call(zoom);
}

function update(commits) {
    console.log("Updating...");
    var g = new dagreD3.Digraph();
    addCommitNodes(g, commits);
    addEdges(g, commits);
    draw(g);
}

$(function() {
  $.get("/commits", update);
  $("form.navbar-form").on("submit", function(event) {
    event.preventDefault();
    console.log($(this));
    $.get("/commits", $(this).serializeArray(), update);
    return false;
  });
})
