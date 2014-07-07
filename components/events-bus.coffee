Emitter = require("events").EventEmitter

bus = new Emitter
bus.setMaxListeners 0

module.exports = bus
