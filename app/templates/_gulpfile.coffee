gulp      = require "gulp"
gutil     = require "gulp-util"
plugins   = require("gulp-load-plugins")(lazy: false)
compile   = require "gulp-compile-js"


gulp.task "scripts", ->
  sources =[
    "!./src/**/*_test.coffee"
    "./src/**/*.coffee"
  ]
  gulp.src(sources)
  .pipe(compile(coffee:
    bare: true
  ))
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
    "!./app/**/*.spec.js"
  ]
  gulp.watch sources, ["scripts", "karma"]
  return

gulp.task "karma", ->
  child_process = require "child_process"
  child = child_process.fork "./karma-run.coffee"
  child.on "close", (code, signal) ->
    if code
      err =
        message: "Failed: Karma specs!"
      gutil.log gutil.colors.red err.message
      gutil.beep()

    else
      console.log gutil.colors.green "Finished: Karma specs"


gulp.task "default", [
  "scripts"
  "karma"
  "vendorJS"
  "watch"
]