react = require "react/addons"

{code} = react.DOM

module.exports = react.createClass
  displayName: "highlightCode"

  statics:
    replaceTag: "code"

  render: ->
    props =
      className: @props.className
    if @props.highlight
      props.dangerouslySetInnerHTML =
        __html: @props.highlight
    else
      props.children = @props.children
    code props
