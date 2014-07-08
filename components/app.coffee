_ = require "highland"
bus = require "./events-bus"
state = require "./app-state"

loading = require "./behaviors/loading"
navigation = require "./behaviors/navigation"
network = require "./behaviors/network"
rendering = require "./behaviors/rendering"

_ "loader.preload", bus
.through loading.preload
.apply()

_ "router.navigate", bus
.through navigation.navigate
.apply()

_ "router.route", bus
.through loading.load
.through rendering.setPage
.apply()

network.onlineChange()
.each (isOnline) ->
  state.set {isOnline}

navigation.start()
network.start()
