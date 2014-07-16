_ = require "highland"
bean = require "bean"
bus = require "../events-bus"

setState = _.map (state) ->
  state.set "network", state.params
  state

onlineChange = (timeout = 1000) ->
  online = _ "network.online", bus
  .map ->
    online: yes

  offline = _ "network.offline", bus
  .map ->
    online: no

  # Watch changes and debounce
  change = _ [online, offline]
  .merge()
  .debounce timeout

  first = _ [online: navigator.onLine ? yes]

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

module.exports = {start, setState, onlineChange}
