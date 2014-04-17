gulp      = require "gulp"
gutil     = require "gulp-util"
plugins   = require("gulp-load-plugins")(lazy: false)
compile   = require "gulp-compile-js"
karma     = require 'gulp-karma'

gulp.task "scripts", ->
  sources =[
    "!./src/**/*_test.coffee"
    "./src/**/*.coffee"
  ]
  gulp.src(sources)
  .pipe(
    compile
      coffee:
        bare: true
  )
  .pipe(plugins.concat("<%=moduleName%>.js"))
  .pipe gulp.dest("./build")
  return

gulp.task "vendorJS", ->
  sources = [
    "!./bower_components/**/*.min.js"
    "./bower_components/**/*.js"
  ]
  gulp.src(sources)
  .pipe(plugins.concat("vendor.js"))
  .pipe gulp.dest("./build")
  return

gulp.task "watch", ->
  sources = [
    "./src/**/*.coffee"
    "!./src/**/*.spec.coffee"
  ]
  gulp.watch sources, ["scripts", "test"]
  return

gulp.task "tests", ->
  sources = [
    "./src/**/*.spec.coffee"
  ]
  gulp.src('./idontexist')
  .pipe(karma
    configFile: './karma-unit.coffee'
    action: 'run'
  )
  .on 'error', (err) ->
    throw err


gulp.task "default", [
  "scripts"
  "tests"
  "vendorJS"
  "watch"
]