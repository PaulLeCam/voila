react = require "react/addons"

module.exports = react.createClass
  displayName: "rawHTML"
  render: ->
    react.DOM.div dangerouslySetInnerHTML:
      __html: @props.children.toString()
