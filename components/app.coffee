_ = require "highland"
bus = require "./events-bus"

loading = require "./behaviors/loading"
navigation = require "./behaviors/navigation"
rendering = require "./behaviors/rendering"

_ "router.navigate", bus
.through navigation.navigate
.apply()

_ "router.route", bus
.through loading.load
.through rendering.setPage
.apply()

navigation.start()
