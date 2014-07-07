_ = require "highland"
bus = require "../events-bus"
router = require "../router"

navigate = _.map (uri) ->
  router.navigate uri, trigger: on
  uri

start = ->
  _ "route:page", router
  .each (route) ->
    bus.emit "router.route", route

  router.history.start pushState: on

module.exports = {start, navigate}
