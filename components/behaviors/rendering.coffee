_ = require "highland"
react = require "react/addons"

app = null
appComponent = require "../app-component"
container = document.getElementById "content"

renderPage = _.wrapCallback (state, cb) ->
  page = state.next "pages.current"
  next = -> cb null, state
  if app? then app.setPage page, next
  else
    component = appComponent page.props, page.component()
    app = react.renderComponent component, container, next

setPage = _.pipeline(
  _.map renderPage
  _.series()
)

module.exports = {setPage}
