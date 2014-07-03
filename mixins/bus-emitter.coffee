bus = require "../temp/events-bus"

module.exports =
  emit: (args...) ->
    bus.trigger.apply bus, args
