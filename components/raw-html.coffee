react = require "react"

module.exports = react.createClass
  name: "rawHTML"
  render: ->
    react.DOM.div dangerouslySetInnerHTML:
      __html: @props.children.toString()
