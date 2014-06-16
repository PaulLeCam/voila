gulp = require "gulp"
$ = require("gulp-load-plugins")()

path = require "path"
through = require "through2"
CSON = require "cson-safe"
React = require "react"
ReactTools = require "react-tools"
voila = require "./lib/voila"

p =
  assets: "assets/**/*"
  build: "build/"
  components: "components/**/*.coffee"
  contents: "contents/**/*.cson"
  layout: "layout.html"

buildOne = through.obj (file, enc, cb) ->
  data = CSON.parse file.contents.toString()
  unless data.path?
    data.path = file.path
      .replace __dirname + "/contents/", ""
      .replace ".cson", ""

  voila.html2component data.content, (err, Content) ->
    return cb err if err

    Component = voila.Component[ data.component ]
    content = voila.renderComponentToString Component
      title: data.title
      children: Content()

    gulp.src p.layout
    .pipe $.rename "index.html"
    .pipe $.replace "{{title}}", data.title
    .pipe $.replace "{{content}}", content
    .pipe $.replace "{{data}}", JSON.stringify data
    .pipe gulp.dest path.resolve p.build, data.path

    cb()

gulp.task "clean", ->
  gulp.src p.build, read: no
  .pipe $.clean()

gulp.task "assets", ["clean"], ->
  gulp.src p.assets
  .pipe gulp.dest p.build

gulp.task "build", ["clean", "assets"], ->
  gulp.src p.contents
  .pipe buildOne

gulp.task "watch", ["build"], ->
  gulp.watch [
    p.assets
    p.components
    p.contents
  ], ["build"]

gulp.task "default", ["build"]
