fs = require "fs"
_ = require "lodash"
React = require "react"
transform = require("react-tools").transform
html2jsx = require "./html2jsx"

voila = _.clone React
voila.Component = _.clone React.DOM
voila.mappings = {}

componentsDir = __dirname + "/../components/"
components = fs.readdirSync componentsDir
for name in fs.readdirSync componentsDir
  C = require componentsDir + name
  voila.Component[ C.type.displayName ] = C
  voila.mappings[ C.replaceTag ] = C.type.displayName if C.replaceTag

replaceComponent = (js, oldC, newC) ->
  re = new RegExp "Component\.#{ oldC }", "g"
  js.replace re, "Component.#{ newC }"

transformJSX = (jsx, mappings) ->
  js = transform "/** @jsx voila.Component */#{ jsx }"
  js = js.replace "/** @jsx voila.Component */", ""
  js = replaceComponent js, k, v for k, v of mappings
  js += "return NewComponent;"
  js

voila.jsx2component = (jsx, mappings = {}) ->
  code = transformJSX jsx, mappings
  func = Function "React", "voila", code
  func React, voila

voila.html2jsx = html2jsx

voila.html2component = (html, cb) ->
  html2jsx html, (err, jsx) ->
    return cb err if err
    cb null, voila.jsx2component jsx, voila.mappings

module.exports = voila
