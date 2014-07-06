react = require "react/addons"

module.exports = react.createClass
  displayName: "app"

  setPage: (page, cb = ->) ->
    props = page.props
    props.children = page.component()
    @setProps props, cb

  render: ->
    if document? then document.title =
      if @props.title then @props.title + " • Voilà"
      else "Voilà"
    react.DOM.div null, @props.children
