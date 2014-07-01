react = require "react/addons"

# Add events here + state management

{body, div, h1, head, html, link, meta, script, title} = react.DOM

module.exports = react.createClass
  displayName: "layout"
  render: ->
    html null,
      head null,
        meta charSet: "utf-8"
        title null, @props.title
        script src: "/modernizr.js"
        link rel: "stylesheet", href: "/h5bp.css"
        link rel: "stylesheet", href: "/components.css"
        link rel: "stylesheet", href: "/main.css"
      body null,
        div className: "container",
          h1 null, @props.title
          @props.children
        script src: "/bundle.js"
