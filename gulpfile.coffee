gulp = require "gulp"
$ = require("gulp-load-plugins")()

fs = require "fs"
path = require "path"
coffee = require "coffee-script"
_ = require "lodash"

source = require "vinyl-source-stream"
through = require "through2"

browserify = require "browserify"
coffeeify = require "coffeeify"

CSON = require "cson-safe"
React = require "react/addons"
{html2component} = require "./lib/react-transform"

p =
  assets: "assets/**/*"
  build: "build/"
  client: "client/"
  components: "components/**/*.coffee"
  contents: "contents/**/*.cson"
  temp: "temp/"
  templates: "templates/"

path2name = (pth) ->
  pth.replace /\/./g, (match) ->
    match.toUpperCase()

applyComponentsMappings = through.obj (file, enc, cb) ->
  React = require "#{ __dirname }/#{ p.temp }react"
  js = file.contents.toString()
  _.each React.mappings, (dest, src) ->
    js = js.replace "DOM.#{ src }", "DOM.#{ dest }"
  file.contents = new Buffer js
  @push file
  cb()

buildPageHTML = through.obj (file, enc, cb) ->
  pageComponent = require "#{ __dirname }/#{ p.temp }#{ file.data.name }"
  gulp.src p.templates + "layout.html"
  .pipe $.rename "index.html"
  .pipe $.template
    title: file.data.title
    content: React.renderComponentToString pageComponent
    data: JSON.stringify file.data
  .pipe gulp.dest path.resolve p.build, file.data.path
  .on "end", =>
    @push file
    cb()

buildPageComponent = through.obj (file, enc, cb) ->
  gulp.src p.templates + "component.js"
  .pipe $.rename file.data.name + ".js"
  .pipe $.template
    componentName: file.data.name
    title: file.data.title
    BaseComponent: file.data.component
    content: file.contents.toString()
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

getComponentData = through.obj (file, enc, cb) ->
  data = CSON.parse file.contents.toString()

  data.path ?= file.path
    .replace __dirname + "/contents/", ""
    .replace ".cson", ""
  data.name ?= path2name data.path

  file.contents = new Buffer data.content
  file.data = data

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

gulp.task "browserify", ->
  browserify
    entries: "#{ __dirname }/#{ p.client }app.coffee"
    extensions: [".coffee"]
  .transform coffeeify
  .bundle()
  .pipe source "bundle.js"
  .pipe gulp.dest p.build

gulp.task "build", ["clean", "assets", "react"], ->
  gulp.src p.contents
  .pipe getComponentData
  .pipe convertToComponent
  .pipe applyComponentsMappings
  .pipe buildPageComponent
  .pipe buildPageHTML

gulp.task "watch", ["build"], ->
  gulp.watch [
    p.assets
    p.components
    p.contents
  ], ["build"]

gulp.task "default", ["build"]
