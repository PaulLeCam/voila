bus = require "../temp/events-bus"

module.exports =
  emit: (args...) ->
    bus.emit.apply bus, args
