Router = require "ampersand-router"

router = new Router

router.route "*uri(/)", "page"
router.route "", "page"

module.exports = router
