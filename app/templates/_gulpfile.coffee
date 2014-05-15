gulp        = require "gulp"
gutil       = require "gulp-util"
plugins     = require("gulp-load-plugins")(lazy: false)
compile     = require "gulp-compile-js"
karma       = require 'gulp-karma'
chalk       = require "chalk"
path        = require "path"

bowerPkg    = require "./bower.json"

server =
  port: 2342
  livereloadPort: 35729
  basePath: path.join(__dirname)
  _lr: null
  started: null
  start: ->
    console.log chalk.white("Start Express")
    express = require("express")
    app = express()
    app.use require("connect-livereload")()
    app.use express.static(server.basePath)
    app.listen server.port

    app.get '/', (req, res) ->
      res.redirect 'demo/'

    console.log chalk.cyan("Express started: #{server.port}")
    server.started = true
    return

  livereload: ->
    server._lr = require("tiny-lr")()
    server._lr.listen server.livereloadPort
    console.log chalk.cyan("Live-Reload on: #{server.livereloadPort}")
    return

  livestart: ->
    server.start()
    server.livereload()
    return

  notify: (event) ->
    fileName = path.relative(server.basePath, event.path)
    server._lr.changed body:
      files: [fileName]
    return


getVendorSources = (minified = false)->
  sources = []
  for packageName, version of bowerPkg.dependencies
    fileName = packageName
    fileName += '.min' if minified
    sources.push "./bower_components/#{packageName}/#{fileName}.js"
  sources


gulp.task "scripts", ->
  sources =[
    "!./src/**/*.spec.coffee"
    "!./src/demo.coffee"
    "./src/**/*.coffee"
  ]
  gulp.src(sources)
  .pipe(
    compile
      coffee:
        bare: true
  )
  .pipe(plugins.concat("<%= _.slugify(moduleName) %>.js"))
  .pipe gulp.dest("./build")
  return

gulp.task "demoScripts", ->
  sources =[
    "./src/demo.coffee"
  ]
  gulp.src(sources)
  .pipe(
      compile
        coffee:
          bare: true
    )
  .pipe gulp.dest("./demo/js")
  return

gulp.task "vendorJS", ->
  sources = getVendorSources()

  getPackageName = (v) -> v.split('/').reverse()[0]
  console.log chalk.cyan("Adding [#{chalk.magenta(sources.map getPackageName)}] to vendors.js")

  gulp.src(sources)
  .pipe(plugins.concat("vendor.js"))
  .pipe gulp.dest("./build")
  return

gulp.task "livereload", ->
  server.livestart()
  return

gulp.task "watch", ->
  sources = [
    "./src/**/*.coffee"
  ]
  watcher = gulp.watch sources, ["scripts", "demoScripts", "karma-unit"]
  watcher.on 'change', (event) ->
    server.notify event
  return

gulp.task "watchDemoFiles", ->
  sources = [
    "./demo/**/*.html"
    "./demo/**/*.css"
  ]
  gulp.watch sources, (event) ->
    console.log event
    server.notify event
  return

gulp.task "karma-unit", ->
  gulp.src('./idontexist')
  .pipe(karma
    configFile: './karma-unit.coffee'
    action: 'run'
  )
  .on 'error', (err) ->
    throw err
  return

gulp.task "default", [
  "scripts"
  "demoScripts"
  "karma-unit"
  "vendorJS"
  "livereload"
  "watch"
  "watchDemoFiles"
]