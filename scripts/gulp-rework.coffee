
through = require 'through2'
cssWhitespaceCompiler = require 'css-whitespace'

rework = require 'rework'
rework_calc = require 'rework-calc'
rework_vars = require 'rework-vars'
rework_shade = require 'rework-shade'
rework_import = require 'rework-importer'

mixins = {
  appearance: (value) ->
    '-webkit-appearance': value

  transform: (value) ->
    '-webkit-transform' : value
    '-moz-transform'    : value
    '-ms-transform'     : value
    '-o-transform'      : value
    'transform'         : value
}

module.exports = ->
  through.obj (file, enc, cb) ->
    if file.isStream()
      @emit 'error', new gutil.PluginError 'gulp-rework', 'Streaming not supported'
      return cb()

    css = cssWhitespaceCompiler file.contents.toString()
    file.contents = new Buffer(rework(css)
      .use(rework_import
        path: 'styles/app.styl'
        base: 'src/'
        whitespace: true
      )
      .use rework_vars()
      .use rework_calc
      .use rework_shade()
      .use rework.mixin mixins
      .use rework.extend()
      .use rework.ease()
      .use rework.references()
      .use rework.colors()
      .use rework.inline('app/assets/images/')
      .toString()
    )

    @push file
    cb()

