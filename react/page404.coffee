react = require "react/addons"
Page = require "./page"

module.exports = react.createClass
  displayName: "page404"
  render: ->
    @transferPropsTo Page null, @props.children
