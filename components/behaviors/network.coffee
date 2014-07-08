_ = require "highland"
bean = require "bean"
bus = require "../events-bus"

onlineChange = (timeout = 1000) ->
  online = _ "network.online", bus
  .map -> yes

  offline = _ "network.offline", bus
  .map -> no

  # Watch changes and debounce
  change = _ [online, offline]
  .merge()
  .debounce timeout

  first = _ [navigator.onLine ? yes]

  # Send first value ASAP, then debounced changes
  _ [first, change]
  .merge()

start = ->
  _ (push, next) ->
    bean.on window, "online", -> push()
  .each ->
    bus.emit "network.online"

  _ (push, next) ->
    bean.on window, "offline", -> push()
  .each ->
    bus.emit "network.offline"

module.exports = {start, onlineChange}
