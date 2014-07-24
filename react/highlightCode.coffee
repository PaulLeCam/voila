react = require "react/addons"

{code} = react.DOM

module.exports = react.createClass
  displayName: "highlightCode"

  statics:
    replaceTag: "code"

  render: ->
    props =
      dangerouslySetInnerHTML:
        __html: @props.value
    code props
