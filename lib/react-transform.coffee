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
  transform "/** @jsx React.DOM */#{ jsx }"
  .replace "/** @jsx React.DOM */", ""

html2component = (html, mappings = {}, cb) ->
  # Terrible hack to make <pre> code render properly
  # It is processed by highlight.js in the gulpfile, but jsdom will break spacing
  # There must be a better way to do this...
  pres = html.split "<pre>"
  prepared = pres.shift()
  codes = {}
  for pre, i in pres
    parts = pre.split "</pre>"
    key = "code#{ i }"
    lang = null
    code = parts[ 0 ]
    # Extract code class and remove tag
    .replace /<code class="([-_\w\s]*)">/, (match, lng) ->
      lang = lng
      ""
    # Remove closing code tag
    .replace "</code>", ""
    # Replace \n by <br/> - must be done before \s
    .replace /\n/g, "<br/>"
    # Replace \t by 2 &nbsp; - must be done before \s
    .replace /\t/g, "&nbsp;&nbsp;"
    # Replace \s by &nbsp;
    .replace /\s/g, "&nbsp;"
    # Remove added &nbsp; in spans
    .replace /<span&nbsp;class/g, "<span class"
    codes[ key ] = {lang, code}
    prepared += "<pre><code data-replace='#{ key }'></code></pre>#{ parts[ 1 ] }"

  html2jsx prepared, (err, jsx) ->
    if err then cb err
    else
      jsx = jsx.replace /<code data-replace="(code\d)+" \/>/gi, (match, id) ->
        if res = codes[ id ]
          "<code className='#{ res.lang }' value='#{ res.code }'></code>"
      jsx = jsx.replace new RegExp(from, "g"), to for from, to of mappings
      cb null, jsx2component jsx

module.exports = {html2jsx, jsx2component, html2component}
