react = require "./react"
container = document.getElementById "content"

module.exports = (uri) ->
  Modernizr.load
    load: if uri is "index" then "/component.js" else "/#{ uri }/component.js"
    complete: ->
      page = require "page/" + uri
      react.renderComponent page, container
