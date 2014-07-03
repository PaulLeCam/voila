Router = require "ampersand-router"
loadPage = require "./load-page"

router = new Router

router.route "*uri(/)", loadPage
router.route "", -> loadPage "index"

module.exports = router
