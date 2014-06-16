jsdom = require "jsdom"
# Lib from https://github.com/facebook/react/blob/master/docs/_js/html-jsx-lib.js
html2jsxlib = require("fs").readFileSync __dirname + "/html-jsx-lib.js"

module.exports = (html, cb) ->
  jsdom.env
    html: "<html><body></body></html>"
    src: [html2jsxlib]
    done: (err, window) ->
      return cb err if err
      converter = new window.HTMLtoJSX
      jsx = converter.convert html
      window.close()
      cb null, jsx
