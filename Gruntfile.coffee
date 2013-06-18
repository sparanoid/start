"use strict"
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # Load all grunt tasks
  matchdep = require("matchdep")
  matchdep.filterDev("grunt-*").forEach grunt.loadNpmTasks

  # Configurable paths
  coreConfig =
    pkg: grunt.file.readJSON("package.json")
    bower: grunt.file.readJSON(".bowerrc")
    app: "app"
    dist: "dist"
    banner: do ->
      banner = "/*!\n"
      banner += " * (c) <%= core.pkg.author %>.\n *\n"
      banner += " * <%= core.pkg.name %> - v<%= core.pkg.version %> (<%= grunt.template.today('mm-dd-yyyy') %>)\n"
      banner += " * <%= core.pkg.homepage %>\n"
      banner += " * <%= core.pkg.license.type %> - <%= core.pkg.license.url %>\n"
      banner += " */"
      banner

  # Project configurations
  grunt.initConfig
    core: coreConfig

    coffeelint:
      options:
        indentation: 2
        no_stand_alone_at:
          level: "error"
        no_empty_param_list:
          level: "error"
        max_line_length:
          level: "ignore"

      test:
        files:
          src: ["Gruntfile.coffee"]

    recess:
      test:
        files:
          src: ["<%= core.app %>/assets/less/**/*.less"]

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["<%= core.app %>/assets/js/**/*.js", "!<%= core.app %>/assets/js/vendor/*", "test/spec/**/*.js"]

    watch:
      options:
        nospawn: true

      coffee:
        files: ["<%= coffeelint.test.files.src %>"]
        tasks: ["coffeelint"]

      less:
        files: ["<%= recess.test.files.src %>"]
        tasks: ["less:server", "recess"]

      js:
        files: ["<%= core.app %>/assets/js/app.js"]
        tasks: ["uglify:server"]

    connect:
      options:
        port: 9000
        hostname: "0.0.0.0"

      server:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, coreConfig.app)]

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

      dist:
        options:
          middleware: (connect) ->
            [mountFolder(connect, coreConfig.dist)]

    less:
      server:
        options:
          paths: ["<%= core.app %>/assets/less"]
          # Known issue: https://github.com/gruntjs/grunt-contrib-less/issues/57
          # dumpLineNumbers: "all"

        files:
          ".tmp/assets/css/main.css": ["<%= core.app %>/assets/less/main.less"]

      dist:
        options:
          paths: ["<%= core.app %>/assets/less"]

        files:
          "<%= core.dist %>/assets/css/main.css": ["<%= core.app %>/assets/less/main.less"]

    uglify:
      server:
        options:
          # TODO: Not implemented
          sourceMap: ".tmp/assets/js/app.js.map"
          # sourceMapRoot: ""
          # sourceMappingURL: ""

        files:
          ".tmp/assets/js/app.min.js": ["<%= core.bower.directory %>/jquery/jquery.js", "<%= core.app %>/assets/js/app.js"]

      dist:
        options:
          banner: "<%= core.banner %>"
          compress: true
          report: "gzip"

        files:
          "<%= core.dist %>/assets/js/app.min.js": ["<%= core.bower.directory %>/jquery/jquery.js", "<%= core.app %>/assets/js/app.js"]

    htmlmin:
      dist:
        options:
          removeComments: true
          removeCommentsFromCDATA: true
          removeCDATASectionsFromCDATA: true
          collapseWhitespace: false
          collapseBooleanAttributes: true
          removeAttributeQuotes: true
          removeRedundantAttributes: true
          useShortDoctype: false
          removeEmptyAttributes: true
          removeOptionalTags: false
          removeEmptyElements: false

        files: [
          expand: true
          cwd: "<%= core.app %>"
          src: "**/*.html"
          dest: "<%= core.dist %>/"
        ]

    xmlmin:
      dist:
        files: [
          expand: true
          cwd: "<%= core.app %>"
          src: "**/*.xml"
          dest: "<%= core.dist %>/"
        ]

    cssmin:
      dist:
        options:
          banner: "<%= core.banner %>"
          report: "gzip"

        files:
          "<%= core.dist %>/assets/css/main.css": ["<%= core.dist %>/assets/css/main.css"]

    imagemin:
      dist:
        options:
          optimizationLevel: 6

        files: [
          expand: true
          cwd: "<%= core.app %>/assets/img"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= core.dist %>/assets/img"
        ]

    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= core.app %>"
          dest: "<%= core.dist %>"
          src: ["*.{ico,png,txt}", ".htaccess", "assets/img/**/*.{webp,gif}", "assets/font/*"]
        ]

      sync:
        files: [
          expand: true
          dot: true
          cwd: "<%= core.dist %>/"
          src: ["**"]
          dest: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= core.pkg.name %>/"
        ]

    concurrent:
      server: ["watch"]

      dist: ["htmlmin", "cssmin", "imagemin"]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= core.dist %>/*", "!<%= core.dist %>/.git*"]
        ]

      server: ".tmp"

      sync:
        options:
          force: true

        files: [
          src: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= core.pkg.name %>/"
        ]

  grunt.registerTask "server", ["clean:server", "less:server", "uglify:server", "connect:server", "concurrent:server"]
  grunt.registerTask "test", ["coffeelint", "recess"]
  grunt.registerTask "build", ["clean:dist", "test", "less:dist", "uglify:dist", "concurrent:dist", "copy"]
  grunt.registerTask "sync", ["build", "clean:sync", "copy:sync"]
  grunt.registerTask "default", ["build"]
