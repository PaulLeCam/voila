_ = require "highland"
appState = require "../app-state"
bus = require "../events-bus"
router = require "../router"

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

loadAndAddPage = _.pipeline(
  _.map loadPage
  _.series()
  _.map (page) ->
    appState.pages[ page.uri ] = page
    bus.emit "state.pages.add", page
    page
)

getOrLoadPage = (s) ->
  getPage = (uri) ->
    appState.pages[ uri ]

  loaded = s.fork().map getPage
  .filter (p) -> p?

  toLoad = s.fork().reject getPage
  .through loadAndAddPage

  _([loaded, toLoad]).merge()

route = _.pipeline(
  _.through getOrLoadPage
  _.map (page) ->
    appState.currentPage = page
    page
)

navigate = _.map (uri) ->
  router.navigate uri, trigger: on
  uri

start = ->
  _ "route:page", router
  .each (route) ->
    route ?= "index"
    bus.emit "router.route", route

  router.history.start pushState: on

module.exports = {start, navigate, route}
