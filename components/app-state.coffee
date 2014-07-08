_ = require "highland"

clone = require "lodash-node/modern/objects/clone"
last = require "lodash-node/modern/arrays/last"
merge = require "lodash-node/modern/objects/merge"

bus = require "./events-bus"

state = [{}]

# TODO: Add a "low priority" set that keeps all the changes and throttle its actual set

module.exports =
  get: -> clone last state
  set: (data = {}) ->
    currentState = @get()
    newState = merge currentState, data
    state.push newState
    bus.emit "state.change", newState, state
    newState
