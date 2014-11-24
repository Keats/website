var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync = require('browser-sync');
var prefix = require('gulp-autoprefixer');

var sassFiles = './scss/*.scss';


gulp.task('browser-sync', function () {
  browserSync.init(null, {
    open: false,
    server: {
      baseDir: "./html"
    },
    watchOptions: {
      debounceDelay: 1000
    }
  });
});

gulp.task('sass', function() {
    gulp.src(sassFiles)
        .pipe(sass({outputStyle: 'compressed', errLogToConsole: true}))
        .pipe(prefix())  // defauls to > 1%, last 2 versions, Firefox ESR, Opera 12.1
        .pipe(gulp.dest('./html'));
});

gulp.task('watch', ['sass', 'browser-sync'], function () {
    gulp.watch(sassFiles, ['sass']);

    gulp.watch('html/app.css', function(file) {
      if (file.type === "changed") {
        return browserSync.reload(file.path);
      }
    });
});
