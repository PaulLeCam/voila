react = require "react/addons"

{div, h2} = react.DOM

module.exports = react.createClass
  displayName: "page"
  render: ->
    div null,
      h2 null, @props.title
      @props.children
