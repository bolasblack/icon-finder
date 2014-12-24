gulp = require 'gulp'
gulp_if = require 'gulp-if'
gulp_util = require 'gulp-util'
gulp_jade = require 'gulp-jade'
gulp_order = require 'gulp-order'
gulp_coffee = require 'gulp-coffee'
gulp_concat = require 'gulp-concat'
gulp_replace = require 'gulp-replace'
gulp_connect = require 'gulp-connect'
gulp_rework = require './scripts/gulp-rework'

sysPath = require 'path'

Q = require 'q'
_ = require 'lodash'
glob = require 'glob'
mergeStream = require 'merge-stream'
readComponents = require 'read-components'


getVendorFiles = ->
  Q.all([
    Q.denodeify(readComponents)('.', 'bower')
    Q.denodeify(glob)('vendor/**/*')
  ]).then ([packages, vendorFiles]) ->
    _(packages)
      .tap (packages) ->
        packages.sort (a, b) ->
          b.sortingLevel - a.sortingLevel
      .map (packages) ->
        packages.files
      .flatten()
      .tap (filelist) ->
        vendorFiles.forEach (filepath) ->
          filelist.push filepath
      .groupBy (filepath) ->
        switch sysPath.extname filepath
          when '.js', '.coffee' then 'scripts'
          when '.css' then 'styles'
          else 'others'
      .value()


PATHS = {
  assets:
    src: 'app/assets/**/*'
    dest: 'public/'
  partials:
    src: 'app/partials/**/*.jade'
    dest: 'public/partials/'
  scripts:
    src: 'app/**/*.coffee'
    dest: 'public/scripts/'
  styles:
    src: 'app/**/*.styl'
    dest: 'public/styles/'
}


gulp.task 'assets', ->
  uneditableExts = 'png jpg gif eot ttf woff svg'.split ' '

  steams = []

  steams.push(gulp.src PATHS.assets.src
    .pipe gulp_if '**/*.jade', gulp_jade(pretty: true, locale: timestamp: Date.now())
    .on 'error', gulp_util.log
    .pipe gulp.dest PATHS.assets.dest
  )

  steams.push(gulp.src 'bower_components/bootstrap/fonts/**/*'
    .pipe gulp.dest PATHS.assets.dest + 'fonts/'
  )

  mergeStream steams...

gulp.task 'partials', ->
  gulp.src PATHS.partials.src
    .pipe gulp_jade(pretty: true).on 'error', gulp_util.log
    .pipe gulp.dest PATHS.partials.dest

gulp.task 'scripts', ['assets'], ->
  gulp.src PATHS.scripts.src
    .pipe gulp_coffee().on 'error', gulp_util.log
    .pipe(gulp_order [
      '**/index.js'
      '**/*.js'
    ])
    .pipe gulp_concat 'app.js'
    .pipe gulp.dest PATHS.scripts.dest

gulp.task 'styles', ['assets'], ->
  gulp.src PATHS.styles.src
    .pipe gulp_if '**/*.styl', gulp_rework().on 'error', gulp_util.log
    .pipe gulp_concat 'app.css'
    .pipe gulp.dest PATHS.styles.dest

gulp.task 'vendor', ->
  getVendorFiles().then (vendorFiles) ->
    unless _(vendorFiles.scripts).isEmpty()
      gulp.src vendorFiles.scripts
        .pipe gulp_if '**/*.coffee', gulp_coffee().on 'error', gulp_util.log
        .pipe gulp_concat 'vendor.js'
        .pipe gulp.dest PATHS.scripts.dest

    unless _(vendorFiles.styles).isEmpty()
      gulp.src vendorFiles.styles
        .pipe gulp_concat 'vendor.css'
        .pipe gulp.dest PATHS.styles.dest

    vendorFiles

gulp.task 'server', ->
  gulp_connect.server(
    port: 9000
    root: 'public'
    livereload: true
  )

gulp.task 'watch', ->
  _(PATHS).forEach (paths, type) ->
    gulp.task "reload_#{type}", [type], ->
      gulp.src(paths.src).pipe gulp_connect.reload()
    gulp.watch paths.src, ["reload_#{type}"]

  gulp.task "reload_vendor", ['vendor'], ->
    gulp.src ["#{PATHS.scripts.dest}/vendor.js", "#{PATHS.scripts.dest}/vendor.css"]
      .pipe gulp_connect.reload()
  gulp.watch 'bower.json', ['reload_vendor']
  return

gulp.task 'build', ['assets', 'partials', 'scripts', 'styles', 'vendor']

gulp.task 'default', ['build', 'server', 'watch']
