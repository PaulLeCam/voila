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
      if nextProps.href and nextProps.href[0] is "/"
        nextProps.href.replace /^\//, ""
      else null
    @setState {uri}

  componentWillMount: ->
    @handleStateChange @appState.get()
    @appState.onChange @handleStateChange

  componentWillUnmount: ->
    @appState.offChange @handleStateChange

  handleStateChange: (s) ->
    state =
      online: s.network?.online ? yes
    if @state.uri?
      uri = if @state.uri is "" then "index" else @state.uri
      state.loaded = !!s.pages?.cache?[ uri ]
    @setState state

  handleClick: (e) ->
    e.preventDefault()
    @emit "router.navigate", uri: @state.uri

  render: ->
    props = {}
    if @state.uri?
      props.onClick = @handleClick
      @emit "loader.preload", uri: @state.uri
    props.className = react.addons.classSet
      smartlink: on
      "smartlink--offline": not @state.online and not @state.loaded
      "smartlink--loaded": @state.loaded and not @state.online

    @transferPropsTo a props, @props.children
