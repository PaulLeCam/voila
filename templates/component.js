var React = require("./react");

module.exports = exports = {};

exports.props = {
  name: "${ name }",
  title: "${ title }"
};

exports.component = React.createClass({
  displayName: "${ name }Page",
  render: function() {
    return React.DOM.${ component }(
      {title: "${ title }"},
      ${ contents.toString() }
    );
  }
});
