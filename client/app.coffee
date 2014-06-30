router = require "./router"
router.history.start pushState: on

router.on "route", (route) ->
  console.log "route", route
