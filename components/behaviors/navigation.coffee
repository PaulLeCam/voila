_ = require "highland"
bus = require "../events-bus"
router = require "../router"

navigate = _.map (state) ->
  uri = state.params.uri
  if uri isnt state.get "pages.current.uri"
    router.navigate uri, trigger: on
    state.set "pages.current.uri", uri
  state

start = ->
  _ "route:page", router
  .each (uri) ->
    uri ?= "index"
    bus.emit "router.route", {uri}

  router.history.start pushState: on

module.exports = {start, navigate}
