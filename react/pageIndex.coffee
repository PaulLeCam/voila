react = require "react/addons"
Page = require "./page"

module.exports = react.createClass
  displayName: "pageIndex"
  render: ->
    @transferPropsTo Page null, @props.children
