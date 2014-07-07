bus = require "../temp/events-bus"
state = require "../temp/app-state"

appState =
  get: state.get
  onChange: (cb) ->
    bus.on "state.change", cb
  offChange: (cb) ->
    bus.removeListener "state.change", cb

module.exports = {appState}
