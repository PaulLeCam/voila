_ = require "highland"
debug = require "debug"
bus = require "./events-bus"
state = require "./state"

loading = require "./behaviors/loading"
navigation = require "./behaviors/navigation"
network = require "./behaviors/network"
rendering = require "./behaviors/rendering"

emitState = (stateData) ->
  bus.emit "state.change", stateData

busProcess = (event, process) ->
  _ event, bus
  .through state.process process
  .each emitState

busProcess "loader.preload", loading.preload

busProcess "router.navigate", navigation.navigate

busProcess "router.route", [
  loading.load
  rendering.setPage
]

network.onlineChange()
.through state.process network.setState
.each emitState

debug.enable "*"

navigation.start()
network.start()
