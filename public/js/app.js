function addToList(commits) {
    var list = $(".commits");
    $(commits).each(function (i, commit) {
      list.append("<li>"+commit["oid"]+": "+commit["message"]+"</li>");
    });
}

function addNodes(g, commits) {
    $(commits).each(function (i, commit) {
      var oid = commit["oid"];
      g.addNode(oid, { label: commit["message"] });
    });
}

function addEdges(g, commits) {
  $(commits).each(function (i, commit) {
    var oid = commit["oid"];
    $(commit["parents"]).each(function(i, parent_oid) {
      console.log(oid, parent_oid);
      //g.addEdge(oid, parent_oid);
      console.log("aft commit ", i)
    });
  });
}

function draw(g) {
  var renderer = new dagreD3.Renderer();
  renderer.run(g, d3.select("svg g"));
}

$(function() {
  $.get("/commits", function (commits) {
    var g = new dagreD3.Digraph();
    addToList(commits);
    addNodes(g, commits);
    addEdges(g, commits);
    draw(g);
  })
})
