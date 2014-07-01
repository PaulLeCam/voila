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
  client: "client/**/*"
  components: "components/**/*.coffee"
  contents: "contents/**/*.cson"
  temp: "temp/"
  templates: "templates/"

# Setup static server
server = express()
# server.use livereload port: lrport
server.use express.static "#{ __dirname }/#{ p.build }"

# Streams

applyComponentsMappings = ->
  through.obj (file, enc, cb) ->
    React = require "#{ __dirname }/#{ p.temp }react"
    js = file.contents.toString()
    _.each React.mappings, (dest, src) ->
      js = js.replace "DOM.#{ src }", "DOM.#{ dest }"
    file.contents = new Buffer js
    @push file
    cb()

buildPageScript = ->
  through.obj (file, enc, cb) ->
    browserify()
    .external ["./react"]
    .require "#{ __dirname }/#{ p.temp }#{ file.name }", expose: "page/#{ file.name }"
    .bundle()
    .pipe source "component.js"
    .pipe gulp.dest path.resolve p.build, file.path
    .on "end", =>
      @push file
      cb()

buildPageHTML = ->
  through.obj (file, enc, cb) ->
    pageComponent = require "#{ __dirname }/#{ p.temp }#{ file.name }"
    html = React.renderComponentToString pageComponent

    $.file "index.html", html
    .pipe gulp.dest path.resolve p.build, file.path
    # End event not emitted, why?
    .on "data", =>
      @push file
      cb()

# Change file object to have props of the component
buildPageComponent = ->
  through.obj (file, enc, cb) ->
    gulp.src p.templates + "component.js"
    .pipe $.rename file.name + ".js"
    .pipe $.template file
    .pipe gulp.dest p.temp
    .on "end", =>
      @push file
      cb()

# Parse HTML and convert it to a React component
convertToComponent = ->
  through.obj (file, enc, cb) ->
    html2component file.contents.toString(), (err, js) =>
      return cb err if err
      file.contents = new Buffer js
      @push file
      cb()

resetPath = ->
  through.obj (file, enc, cb) ->
    file.path = $.util.replaceExtension file.path, ""
    @push file
    cb()

# Open a CSON file, parse its contents and assign them to the file object
getContent = ->
  through.obj (srcFile, enc, cb) ->
    data = CSON.parse srcFile.contents.toString()

    file = new $.util.File
      contents: new Buffer data.contents

    file.path = data.path ? srcFile.path
      .replace __dirname + "/contents/", ""
      .replace ".cson", ""

    file.name = data.name ? file.path.replace /\/./g, (match) ->
      match.toUpperCase()

    _.defaults file, data

    @push file
    cb()

gulp.task "clean", ->
  gulp.src [p.build, p.temp], read: no
  .pipe $.rimraf()

gulp.task "assets", ["clean"], ->
  gulp.src p.assets
  .pipe gulp.dest p.build

gulp.task "react", ["clean"], ->
  gulp.src p.templates + "react.js"
  .pipe $.template
    components: fs.readdirSync __dirname + "/components"
  .pipe gulp.dest p.temp

gulp.task "client", ["clean"], ->
  gulp.src p.client
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
  .pipe getContent()
  .pipe $.markdown()
  .pipe resetPath()
  .pipe convertToComponent()
  .pipe applyComponentsMappings()
  .pipe buildPageComponent()
  .pipe buildPageHTML()
  .pipe buildPageScript()

gulp.task "watch", ["build"], ->
  gulp.watch [
    p.assets
    p.client
    p.components
    p.contents
  ], ["build"]

gulp.task "serve", ["build"], ->
  server.listen serverport
  # lrserver.listen lrport

gulp.task "dev", ["serve", "watch"]

gulp.task "default", ["build"]
