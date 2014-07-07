_ = require "highland"
state = require "../app-state"
bus = require "../events-bus"

processUri = (uri) ->
  uri = "index" if uri is "" or not uri?
  uri

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

addPage = (page) ->
  st = pages: {}
  st.pages[ page.uri ] = page
  state.set st
  page

getPage = (uri) ->
  state.get().pages?[ uri ]

loadAndAdd = (s) ->
  s.map loadPage
  .series()
  .map addPage

load = (s) ->
  p = s.map processUri

  loaded = p.fork()
  .map getPage
  .compact()

  toLoad = p.fork()
  .reject getPage
  .through loadAndAdd

  _([loaded, toLoad]).merge()

preload = _.pipeline(
  _.map processUri
  _.reject getPage
  _.through loadAndAdd
)

module.exports = {load, preload}
