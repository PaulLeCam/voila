_ = require "highland"
clone = require "lodash-node/modern/objects/clone"
debug = require("debug") "voila:behavior:loading"
bus = require "../events-bus"

processUri = (state) ->
  state.params.uri = "index" if state.params.uri is ""
  state

loadPage = _.wrapCallback (state, cb) ->
  uri = state.params.uri
  debug "loadPage:load #{ uri }"
  Modernizr.load
    load: if uri is "index" then "/component.js" else "/#{ uri }/component.js"
    complete: ->
      debug "loadPage:complete #{ uri }"
      try
        page = require "page/" + uri.replace /\/$/, ""
        page.uri = uri
        state.params.loaded = page
        debug "loadPage:loaded #{ uri }", page
      catch err
        debug "loadPage:error #{ uri }", err
      finally
        cb err, state

addPage = (state) ->
  if page = state.params.loaded
    debug "addPage: #{ page.uri }"
    state.set "pages.cache.#{ page.uri }", clone page
  state

getPage = (state) ->
  state if state.get "pages.cache." + state.params.uri

setPage = (state) ->
  key = "pages.cache." + state.params.uri
  if page = state.get(key) ? state.next key
    state.set "pages.current", clone page
  state

loadAndAdd = (stream) ->
  stream.map loadPage
  .series()
  .map addPage

load = (stream) ->
  p = stream.map processUri

  loaded = p.fork()
  .map getPage
  .compact()

  toLoad = p.fork()
  .reject getPage
  .through loadAndAdd

  _ [loaded, toLoad]
  .merge()
  .map setPage

preload = _.pipeline(
  _.map processUri
  _.reject getPage
  _.through loadAndAdd
)

module.exports = {load, preload}
