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
  var rendered = renderer.layout(layout).run(g, d3.select("svg g"));
  console.log("rd ", rendered)
  console.log("Setting width ", rendered._value.width);
  $("#commits-graph").width(rendered._value.width);
}

$(function() {
  $.get("/commits", function (commits) {
    var g = new dagreD3.Digraph();
    addToList(commits);
    addCommitNodes(g, commits);
    addEdges(g, commits);
    draw(g);
  })
})
