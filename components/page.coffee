react = require "react/addons"
layout = require "./layout"

{div, h2} = react.DOM

module.exports = react.createClass
  displayName: "page"
  render: ->
    layout null,
      h2 null, @props.title
      @props.children
