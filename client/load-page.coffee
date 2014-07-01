react = require "./react"

module.exports = (uri) ->
  Modernizr.load
    load: if uri is "index" then "/component.js" else "/#{ uri }/component.js"
    complete: ->
      page = require "page/" + uri
      react.renderComponent page, document
