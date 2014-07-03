app = require "./app-component"
bus = require "./events-bus"
react = require "./react"
router = require "./router"

bus.on "page:navigate", (uri) ->
  router.navigate uri, trigger: on

# Render on first page load only, other ones will be handled by the component
bus.once "page:loaded", (page) ->
  react.renderComponent app(page.props, page.component()), document.getElementById "content"

router.history.start pushState: on
