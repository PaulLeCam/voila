# Core dependencies
fs = require "fs"
path = require "path"
_ = require "highland"

# Utils
defaults = require "lodash-node/modern/objects/defaults"
forEach = require "lodash-node/modern/collections/forEach"

# Gulp + streams
gulp = require "gulp"
$ = require("gulp-load-plugins")()
source = require "vinyl-source-stream2"

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
  components: "components/**/*.coffee"
  contents: "contents/**/*.cson"
  temp: "temp/"
  templates: "templates/"
  react: "react/**/*"

# Setup static server
server = express()
server.use livereload port: lrport
server.use express.static "#{ __dirname }/#{ p.build }"

# Utils
getFiles = (pth) ->
  fs.readdirSync(__dirname + "/" + pth).filter (f) ->
    fs.statSync(__dirname + "/" + pth + "/" + f).isFile() and f[0] isnt "."

# Streams

# posts = contents.fork()
# .filter (file) ->
#   file.type is "post"

# Open a CSON file, parse its contents and assign them to the file object
getContent = (srcFile) ->
  data = CSON.parse srcFile.contents.toString()

  file = new $.util.File
    contents: new Buffer data.contents

  file.path = data.path ? srcFile.path
    .replace __dirname + "/contents/", ""
    .replace ".cson", ""
  file.name = data.name ? file.path.replace /\/./g, (match) ->
    match.toUpperCase()

  defaults file, data

resetPath = (file) ->
  file.path = $.util.replaceExtension file.path, ""
  file

# Parse HTML and convert it to a React component
convertToComponent = _.wrapCallback (file, cb) ->
  html2component file.contents.toString(), (err, js) ->
    return cb err if err
    file.contents = new Buffer js
    cb null, file

applyComponentsMappings = (file) ->
  React = require "#{ __dirname }/#{ p.temp }react"
  js = file.contents.toString()
  forEach React.mappings, (dest, src) ->
    re = new RegExp "DOM\.#{ src }", "g"
    js = js.replace re, "DOM.#{ dest }"
  file.contents = new Buffer js
  file

# Change file object to have props of the component
buildPageComponent = _.wrapCallback (file, cb) ->
  gulp.src p.templates + "component.js"
  .pipe $.rename file.name + ".js"
  .pipe $.template file
  .pipe gulp.dest p.temp
  .on "end", ->
    cb null, file

buildPageHTML = _.wrapCallback (file, cb) ->
  app = require "#{ __dirname }/#{ p.temp }app-component"
  page = require "#{ __dirname }/#{ p.temp }#{ file.name }"

  gulp.src p.templates + "index.html"
  .pipe $.template
    title: page.props.title
    content: React.renderComponentToString app page.props, page.component()
  .pipe gulp.dest path.resolve p.build, file.path
  .on "end", ->
    cb null, file

buildPageScript = _.wrapCallback (file, cb) ->
  browserify()
  .external ["./react"]
  .require "#{ __dirname }/#{ p.temp }#{ file.name }", expose: "page/#{ file.name }"
  .bundle()
  .pipe source "component.js"
  .pipe gulp.dest path.resolve p.build, file.path
  .on "end", ->
    cb null, file

contents = gulp
.src p.contents
.pipe _()
.map getContent

# Tasks

gulp.task "clean", ->
  gulp.src [p.build, p.temp], read: no
  .pipe $.rimraf()

gulp.task "assets", ["clean"], ->
  gulp.src p.assets
  .pipe gulp.dest p.build

gulp.task "less", ["clean"], ->
  gulp.src "./styles.less"
  .pipe $.less()
  .pipe gulp.dest p.build

gulp.task "react", ["clean"], ->
  gulp.src p.templates + "react.js"
  .pipe $.template
    components: getFiles "react"
  .pipe gulp.dest p.temp

gulp.task "components", ["clean"], ->
  gulp.src p.components
  .pipe gulp.dest p.temp

gulp.task "browserify", ["react", "components"], ->
  browserify
    entries: "#{ __dirname }/#{ p.temp }app.coffee"
    extensions: [".coffee"]
  .require "#{ __dirname }/#{ p.temp }react", expose: "./react"
  .require "#{ __dirname }/#{ p.temp }events-bus", expose: "./events-bus"
  .transform coffeeify
  .bundle()
  .pipe source "bundle.js"
  .pipe gulp.dest p.build

gulp.task "build", ["clean", "assets", "less", "react", "browserify"], ->
  contents.fork()
  .pipe $.markdown()
  .pipe _()
  .flatten()
  .map resetPath
  .map convertToComponent
  .flatten()
  .map applyComponentsMappings
  .map buildPageComponent
  .flatten()
  .map buildPageHTML
  .flatten()
  .map buildPageScript
  .flatten()
  .each (file) ->
    $.util.log "Created page", $.util.colors.green file.name

gulp.task "watch", ["build"], ->
  gulp.watch [
    p.assets
    p.components
    p.contents
    p.react
  ], ["build"]

gulp.task "serve", ["build"], ->
  server.listen serverport
  lrserver.listen lrport

gulp.task "dev", ["serve", "watch"]

gulp.task "default", ["build"]
