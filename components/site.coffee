react = require "react"

{div, h1} = react.DOM

module.exports = react.createClass
  displayName: "site"
  render: ->
    div null,
      h1 null, "My site title"
      @props.children