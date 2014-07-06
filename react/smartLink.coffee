react = require "react/addons"
emitterMixin = require "../mixins/bus-emitter"

{a} = react.DOM

module.exports = react.createClass
  displayName: "smartLink"

  mixins: [emitterMixin]
  statics:
    replaceTag: "a"

  handleClick: (e) ->
    e.preventDefault()
    @emit "router.navigate", @props.href

  render: ->
    props = {}
    if @props.href and @props.href[0] is "/"
      props.onClick = @handleClick

    @transferPropsTo a props, @props.children
