var React = require("./react");

var ContentComponent = React.createClass({
  displayName: "${ componentName }Page",
  render: function() {
    return ${ contents }
  }
});

module.exports = React.DOM.${ BaseComponent }({title: "${ title }"}, ContentComponent());
