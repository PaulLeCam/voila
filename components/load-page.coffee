bus = require "./events-bus"

module.exports = (uri) ->
  Modernizr.load
    load: if uri is "index" then "/component.js" else "/#{ uri }/component.js"
    complete: ->
      page = require "page/" + uri.replace /\/$/, ""
      bus.trigger "page:loaded", page
