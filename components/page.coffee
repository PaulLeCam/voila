react = require "react"
site = require "./site"
raw = require "./raw-html"

{div, h2} = react.DOM

module.exports = react.createClass
  name: "page"
  render: ->
    site null,
      h2 null, @props.title
      raw null, @props.children
