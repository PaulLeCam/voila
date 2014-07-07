_ = require "highland"
react = require "react/addons"

emitterMixin = require "../mixins/bus-emitter"
stateMixin = require "../mixins/app-state"

{a} = react.DOM

module.exports = react.createClass
  displayName: "smartLink"

  mixins: [
    emitterMixin
    stateMixin
  ]
  statics:
    replaceTag: "a"

  getInitialState: ->
    state = {}
    if @props.href and @props.href[0] is "/"
      state.uri = @props.href.replace /^\//, ""
    state

  componentWillReceiveProps: (nextProps) ->
    uri =
      if @nextProps.href and @nextProps.href[0] is "/"
        nextProps.href.replace /^\//, ""
      else no
    @setState {uri}

  componentWillMount: ->
    if @state.uri?
      @detectLoaded @appState.get()
      @appState.onChange @detectLoaded

  componentWillUnmount: ->
    @appState.offChange @detectLoaded

  detectLoaded: (s) ->
    uri = if @state.uri is "" then "index" else @state.uri
    @setState loaded: s.pages?[ uri ]

  handleClick: (e) ->
    e.preventDefault()
    @emit "router.navigate", @state.uri

  render: ->
    props = {}
    if @state.uri?
      props.onClick = @handleClick
      @emit "loader.preload", @state.uri
    props.className = react.addons.classSet
      smartlink: on
      "smartlink--loaded": @state.loaded

    @transferPropsTo a props, @props.children
