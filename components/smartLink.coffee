react = require "react/addons"

{a} = react.DOM

module.exports = react.createClass
  displayName: "smartLink"
  statics:
    replaceTag: "a"
  render: ->
    @transferPropsTo a className: "smartlink", @props.children
