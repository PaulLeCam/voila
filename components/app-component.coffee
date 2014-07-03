react = require "react/addons"
listenerMixin = require "../mixins/bus-listener"

module.exports = react.createClass
  displayName: "app"
  mixins: [listenerMixin]

  componentWillMount: ->
    @on "page:loaded", @setPage

  componentWillUnmount: ->
    @off "page:loaded", null, @

  setPage: (page) ->
    document.title =
      if page.props?.title then page.props.title + " • Voilà"
      else "Voilà"
    @setProps children: page.component()

  render: ->
    react.DOM.div null, @props.children
