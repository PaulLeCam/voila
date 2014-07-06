_ = require "highland"
bus = require "./events-bus"
navigation = require "./behaviors/navigation"
rendering = require "./behaviors/rendering"

_ "router.navigate", bus
.through navigation.navigate
.apply()

_ "router.route", bus
.through navigation.route
.through rendering.setPage
.apply()

navigation.start()
