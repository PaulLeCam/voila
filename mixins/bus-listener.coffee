bus = require "../temp/events-bus"

module.exports =
  on: (args...) -> bus.on.apply bus, args
  once: (args...) -> bus.once.apply bus, args
  off: (args...) -> bus.off.apply bus, args
