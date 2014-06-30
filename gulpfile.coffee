# Core dependencies
fs = require "fs"
path = require "path"
_ = require "lodash"

# Gulp + streams
gulp = require "gulp"
$ = require("gulp-load-plugins")()
source = require "vinyl-source-stream2"
through = require "through2"

# Browserify
browserify = require "browserify"
coffeeify = require "coffeeify"

# Libs for tasks
CSON = require "cson-safe"
React = require "react/addons"
{html2component} = require "./lib/react-transform"

# Static server + livereload
express = require "express"
refresh = require "gulp-livereload"
lrserver = require("tiny-lr")()
livereload = require "connect-livereload"

# Params
serverport = 3000
lrport = 35729
p =
  assets: "assets/**/*"
  build: "build/"
  client: "client/"
  components: "components/**/*.coffee"
  contents: "contents/**/*.cson"
  temp: "temp/"
  templates: "templates/"

# Setup static server
server = express()
# server.use livereload port: lrport
server.use express.static "#{ __dirname }/#{ p.build }"

# Streams

applyComponentsMappings = through.obj (file, enc, cb) ->
  React = require "#{ __dirname }/#{ p.temp }react"
  js = file.contents.toString()
  _.each React.mappings, (dest, src) ->
    js = js.replace "DOM.#{ src }", "DOM.#{ dest }"
  file.contents = new Buffer js
  @push file
  cb()

buildPageScript = through.obj (file, enc, cb) ->
  browserify()
  .external ["./react"]
  .require "#{ __dirname }/#{ p.temp }#{ file.data.name }", expose: "page/#{ file.data.name }"
  .bundle()
  .pipe source "component.js"
  .pipe gulp.dest path.resolve p.build, file.data.path
  .on "end", =>
    @push file
    cb()

buildPageHTML = through.obj (file, enc, cb) ->
  pageComponent = require "#{ __dirname }/#{ p.temp }#{ file.data.name }"
  html = React.renderComponentToString pageComponent

  $.file "index.html", html
  .pipe gulp.dest path.resolve p.build, file.data.path
  # End event not emitted, why?
  .on "data", =>
    @push file
    cb()

# Change file object to have props of the component
buildPageComponent = through.obj (file, enc, cb) ->
  gulp.src p.templates + "component.js"
  .pipe $.rename file.data.name + ".js"
  .pipe $.template
    componentName: file.data.name
    title: file.data.title
    BaseComponent: file.data.component
    contents: file.contents.toString()
  .pipe gulp.dest p.temp
  .on "end", =>
    @push file
    cb()

convertToComponent = through.obj (file, enc, cb) ->
  html2component file.contents.toString(), (err, js) =>
    return cb err if err
    file.contents = new Buffer js
    @push file
    cb()

path2name = (pth) ->
  pth.replace /\/./g, (match) ->
    match.toUpperCase()

getComponentData = through.obj (file, enc, cb) ->
  data = CSON.parse file.contents.toString()

  data.path ?= file.path
    .replace __dirname + "/contents/", ""
    .replace ".cson", ""
  data.name ?= path2name data.path

  file.contents = new Buffer data.contents
  file.data = data

  @push file
  cb()

# Open a CSON file, parse its contents and assign them to the file object
getContent = through.obj (srcFile, enc, cb) ->
  data = CSON.parse srcFile.contents.toString()
  file = new $.util.File data

  file.path ?= srcFile.path
    .replace __dirname + "/contents/", ""
    .replace ".cson", ""
  file.name ?= path2name file.path
  file.contents = new Buffer data.contents

  @push file
  cb()

gulp.task "clean", ->
  gulp.src [p.build, p.temp], read: no
  .pipe $.clean()

gulp.task "assets", ["clean"], ->
  gulp.src p.assets
  .pipe gulp.dest p.build

gulp.task "react", ["clean"], ->
  gulp.src p.templates + "react.js"
  .pipe $.template
    components: fs.readdirSync __dirname + "/components"
  .pipe gulp.dest p.temp

gulp.task "client", ["clean"], ->
  gulp.src p.client + "**"
  .pipe gulp.dest p.temp

gulp.task "browserify", ["react", "client"], ->
  browserify
    entries: "#{ __dirname }/#{ p.temp }app.coffee"
    extensions: [".coffee"]
  .require "#{ __dirname }/#{ p.temp }react", expose: "./react"
  .transform coffeeify
  .bundle()
  .pipe source "bundle.js"
  .pipe gulp.dest p.build

gulp.task "build", ["clean", "assets", "react", "browserify"], ->
  gulp.src p.contents
  .pipe getComponentData
  .pipe convertToComponent
  .pipe applyComponentsMappings
  .pipe buildPageComponent
  .pipe buildPageHTML
  .pipe buildPageScript

  # getContent
  # apply content filters (markdown, etc)
  # convert content to component
  # apply component filters (mappings)
  # write component
  # parallel call to writing functions for JS and HTML files

gulp.task "serve", ->
  server.listen serverport
  # lrserver.listen lrport

gulp.task "watch", ["build"], ->
  gulp.watch [
    p.assets
    p.client
    p.components
    p.contents
  ], ["build"]

gulp.task "dev", ["serve", "browserify", "watch"]

gulp.task "default", ["build", "browserify"]
