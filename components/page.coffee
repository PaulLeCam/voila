react = require "react"
site = require "./site"

{div, h2} = react.DOM

module.exports = react.createClass
  displayName: "page"
  render: ->
    site null,
      h2 null, @props.title
      @props.children
