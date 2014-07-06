_ = require "highland"
appState = require "../app-state"
bus = require "../events-bus"

loadPage = _.wrapCallback (uri, cb) ->
  Modernizr.load
    load: if uri is "index" then "/component.js" else "/#{ uri }/component.js"
    complete: ->
      try
        page = require "page/" + uri.replace /\/$/, ""
        page.uri = uri
        cb null, page
      catch err
        cb err

loadAndAdd = _.pipeline(
  _.map loadPage
  _.series()
  _.map (page) ->
    appState.pages[ page.uri ] = page
    bus.emit "state.pages.add", page
    page
)

load = (s) ->
  get = (uri) ->
    appState.pages[ uri ]

  loaded = s.fork().map get
  .filter (p) -> p?

  toLoad = s.fork().reject get
  .through loadAndAdd

  _([loaded, toLoad]).merge()

module.exports = {load}
