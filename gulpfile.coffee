'use strict'
gulp         = require('gulp')
jade         = require('gulp-jade')
minifyHTML   = require('gulp-minify-html')
sass         = require('gulp-sass')
coffee       = require('gulp-coffee')
minifycss    = require('gulp-minify-css')
autoprefixer = require('gulp-autoprefixer')
jshint       = require('gulp-jshint')
uglify       = require('gulp-uglify')
stylish      = require('jshint-stylish')
rename       = require('gulp-rename')
concat       = require('gulp-concat')
notify       = require('gulp-notify')
gutil        = require('gulp-util');
plumber      = require('gulp-plumber')
browserSync  = require('browser-sync')

reload       = browserSync.reload

# gulp.task 'coffee', ->
#   gulp.src('./src/*.coffee').pipe(coffee(bare: true).on('error', gutil.log)).pipe gulp.dest('./public/')


target =
  template_src: 'dev/templates/*.jade'
  sass_src: 'dev/scss/**/*.scss'
  cs_src: 'dev/js/*.coffee'
  js_lint_src: [ 'js/**/*.js' ]
  js_uglify_src: [ '' ]
  js_concat_src: [ 'js/**/*.js' ]
  css_dest: 'prod/css'
  js_dest: 'prod/js'

gulp.task 'compile-coffee', ->
  gulp.src(target.cs_src)
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./prod/js'))

gulp.task 'minify-html', ->
  opts =
    comments: false
    spare: true
  gulp.src('./prod/*.html').pipe(minifyHTML(opts)).pipe gulp.dest('html')

gulp.task 'sass', ->
  gulp.src(target.sass_src).pipe(plumber()).pipe(sass()).pipe(autoprefixer('last 2 version', '> 1%', 'ie 8', 'ie 9', 'ios 6', 'android 4')).pipe(minifycss()).pipe(concat('main.css')).pipe(gulp.dest(target.css_dest)).pipe reload(stream: true)
  #        .pipe(notify({message: 'SCSS processed!'}));    // notify when done

# lint my custom js
gulp.task 'js-lint', ->
  gulp.src(target.js_lint_src).pipe(jshint()).pipe jshint.reporter(stylish)
  # present the results in a beautiful way

# minify all js files that should not be concatinated
gulp.task 'js-uglify', ->
  gulp.src(target.js_uglify_src).pipe(uglify()).pipe(rename((dir, base, ext) ->
    # give the files a min suffix
    trunc = base.split('.')[0]
    trunc + '.min' + ext
  )).pipe gulp.dest(target.js_dest)
  # where to put the files
  #        .pipe(notify({ message: 'JS uglified'}));     // notify when done

# minify & concatinate all other js
gulp.task 'js-concat', ->
  gulp.src(target.js_concat_src).pipe(uglify()).pipe(concat('main.min.js')).pipe gulp.dest(target.js_dest)
  # where to put the files
  #        .pipe(notify({message: 'JS concatinated'}));      // notify when done

# Static server
gulp.task 'browser-sync', ->
  browserSync
    proxy: 'http://localhost:3003'


gulp.task 'templates', ->
  gulp.src('dev/templates/*.jade').pipe(plumber()).pipe(jade(pretty: true)).pipe(gulp.dest('./prod/')).pipe reload(stream: true)

# Default task to be run with `gulp`
gulp.task 'default', [
  'templates'
  'browser-sync'
  'sass'
], ->
  gulp.watch target.template_src, [
    'templates'
    'minify-html'
  ]
  gulp.watch target.sass_src, [ 'sass' ]
  gulp.watch target.cs_src, ['compile-coffee']
  gulp.watch target.js_lint_src, [ 'js-lint' ]
  gulp.watch target.js_minify_src, [ 'js-uglify' ]
  gulp.watch target.js_concat_src, [ 'js-concat' ]
