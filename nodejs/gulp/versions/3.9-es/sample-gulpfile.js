"use strict";

var browserify = require('browserify');
var gulp = require('gulp');
var shell = require('gulp-shell');
var autoprefixer = require("gulp-autoprefixer");
var plumber = require("gulp-plumber");
var rename = require('gulp-rename');
var sass = require("gulp-sass");
let uglify = require('gulp-uglify-es').default;
var eslint = require('gulp-eslint');
var through = require('through2');

gulp.task("js", function() {
  gulp.src('/monitor/app/assets/js/**/*.vue')
      .pipe(eslint('/etc/eslint/eslint.json'))
      .pipe(eslint.formatEach('compact', process.stderr))
      .pipe(rename({extname: '.js'}))
      .pipe(uglify())
      .pipe(gulp.dest("/monitor/app/assets/js/min"));
});

gulp.task("sass", function() {
  gulp.src("/monitor/app/assets/scss/**/*.scss")
      .pipe(plumber())
      .pipe(sass())
      .pipe(autoprefixer())
      .pipe(gulp.dest("/monitor/app/assets/css"));
});

gulp.task("app", function() {
  gulp.src("/app/main.go")
      .pipe(shell(['docker restart app'], {ignoreErrors: true}));
});

gulp.task("default", function() {
    gulp.watch("/monitor/app/**/*.go", ["app"]);
    gulp.watch("/monitor/app/assets/js/**/*.vue", ["js"]);
    gulp.watch("/monitor/app/assets/scss/**/*.scss", ["sass"]);
});
