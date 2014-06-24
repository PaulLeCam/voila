transform = require("react-tools").transform
jsdom = require "jsdom"
# Lib from https://github.com/facebook/react/blob/master/docs/_js/html-jsx-lib.js
html2jsxlib = require("fs").readFileSync __dirname + "/html-jsx-lib.js"

html2jsx = (html, cb) ->
  jsdom.env
    html: "<html><body></body></html>"
    src: [html2jsxlib]
    done: (err, window) ->
      return cb err if err
      converter = new window.HTMLtoJSX createClass: no
      jsx = converter.convert html
      window.close()
      cb null, jsx

jsx2component = (jsx) ->
  js = transform "/** @jsx React.DOM */#{ jsx }"
  js = js.replace "/** @jsx React.DOM */", ""
  js

html2component = (html, cb) ->
  html2jsx html, (err, jsx) ->
    if err then cb err
    else cb null, jsx2component jsx

module.exports = {html2jsx, jsx2component, html2component}
