var React = require("react/addons");

React.mappings = {};

<% _.each(components, function(file) { %>
<% var C = file.replace(".coffee", "") + "Component"; %>

var <%- C %> = require("../components/<%- file %>");
React.DOM[ <%- C %>.type.displayName ] = <%- C %>;
if (<%- C %>.replaceTag) React.mappings[ <%- C %>.replaceTag ] = <%- C %>.type.displayName;

<% }); %>

module.exports = React;
