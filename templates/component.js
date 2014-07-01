var React = require("./react");

var ContentComponent = React.createClass({
  displayName: "${ name }Page",
  render: function() {
    return ${ contents.toString() }
  }
});

module.exports = React.DOM.${ component }({title: "${ title }"}, ContentComponent());
