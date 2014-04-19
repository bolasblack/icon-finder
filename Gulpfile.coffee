gulp = require 'gulp'
gulp_if = require 'gulp-if'
gulp_util = require 'gulp-util'
gulp_order = require 'gulp-order'
gulp_concat = require 'gulp-concat'
gulp_replace = require 'gulp-replace'
gulp_livereload = require 'gulp-livereload'
gulp_jade = require 'gulp-jade'
gulp_coffee = require 'gulp-coffee'
gulp_rework = require './scripts/gulp-rework'

sysPath = require 'path'

Q = require 'q'
_ = require 'lodash'
glob = require 'glob'
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

  gulp.src PATHS.assets.src
    .pipe gulp_if "**/*.+(#{uneditableExts.join '|'})", gulp_replace /{%timestamp%}/g, Date.now()
    .pipe gulp_if '**/*.jade', gulp_jade(pretty: true).on 'error', gulp_util.log
    .pipe gulp.dest PATHS.assets.dest

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

gulp.task 'watch', ->
  livereloadServer = gulp_livereload()

  livereload = (watcher) ->
    watcher.on 'change', triggerLivereload

  triggerLivereload = _.debounce (file) ->
    livereloadServer.changed file.path
  , 500

  livereload gulp.watch PATHS.assets.src, ['assets']
  livereload gulp.watch PATHS.partials.src, ['partials']
  livereload gulp.watch PATHS.scripts.src, ['scripts']
  livereload gulp.watch PATHS.styles.src, ['styles']
  livereload gulp.watch 'bower.json', ['vendor']
  return

gulp.task 'build', ['assets', 'partials', 'scripts', 'styles', 'vendor']

gulp.task 'default', ['build', 'watch']

