"use strict"
LIVERELOAD_PORT = 35728
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # Load all grunt tasks
  matchdep = require("matchdep")
  matchdep.filterDev("grunt-*").forEach grunt.loadNpmTasks

  # Configurable paths
  coreConfig =
    pkg: grunt.file.readJSON("package.json")
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

      gruntfile:
        files:
          src: ["Gruntfile.coffee"]

      test:
        files:
          src: ["<%= core.app %>/assets/coffee/app.coffee"]

    recess:
      test:
        files:
          src: ["<%= core.app %>/assets/less/app.less"]

    connect:
      options:
        port: 9000

        # change this to "0.0.0.0" to access the server from outside
        hostname: "0.0.0.0"

      livereload:
        options:
          middleware: (connect) ->
            [lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, coreConfig.app)]

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

      dist:
        options:
          middleware: (connect) ->
            [mountFolder(connect, coreConfig.dist)]

    watch:
      grunt:
        files: ["<%= coffeelint.gruntfile.files.src %>"]
        tasks: ["coffeelint:gruntfile"]

      coffee:
        files: ["<%= coffeelint.test.files.src %>"]
        tasks: ["coffeelint:test", "coffee"]

      less:
        files: ["<%= core.app %>/assets/less/app.less"]
        tasks: ["less:server", "autoprefixer:server"]

      livereload:
        options:
          livereload: LIVERELOAD_PORT

        files: ["<%= core.app %>/*.html", "{.tmp,<%= core.app %>}/assets/css/{,*/}*.css", "{.tmp,<%= core.app %>}/assets/js/{,*/}*.js", "<%= core.app %>/assets/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"]

    coffee:
      server:
        options:
          sourceMap: true

        files:
          ".tmp/assets/js/app.js": ["<%= core.app %>/assets/coffee/app.coffee"]

      dist:
        files:
          "<%= core.dist %>/assets/js/app.js": ["<%= core.app %>/assets/coffee/app.coffee"]

    less:
      server:
        options:
          strictMath: true
          sourceMap: true
          outputSourceFiles: true
          sourceMapURL: "app.css.map"
          sourceMapFilename: ".tmp/assets/css/app.css.map"

        src: ["<%= core.app %>/assets/less/app.less"]
        dest: ".tmp/assets/css/app.css"

      dist:
        src: ["<%= less.server.src %>"]
        dest: "<%= core.dist %>/assets/css/app.css"

    autoprefixer:
      server:
        src: ["<%= less.server.dest %>"]
        dest: "<%= less.server.dest %>"

      dist:
        src: ["<%= less.dist.dest %>"]
        dest: "<%= less.dist.dest %>"

    htmlmin:
      dist:
        options:
          removeComments: true
          removeCommentsFromCDATA: true
          removeCDATASectionsFromCDATA: true
          collapseWhitespace: true
          conservativeCollapse: true
          collapseBooleanAttributes: true
          removeAttributeQuotes: false
          removeRedundantAttributes: true
          useShortDoctype: false
          removeEmptyAttributes: true
          removeOptionalTags: true
          removeEmptyElements: false
          lint: false
          keepClosingSlash: true
          caseSensitive: true
          minifyJS: true
          minifyCSS: true

        files: [
          expand: true
          cwd: "<%= core.app %>"
          src: "**/*.html"
          dest: "<%= core.dist %>/"
        ]

    cssmin:
      dist:
        options:
          banner: "<%= core.banner %>"
          report: "gzip"

        files: [
          expand: true
          cwd: "<%= core.dist %>/assets/css/"
          src: ["*.css", "!*.min.css"]
          dest: "<%= core.dist %>/assets/css/"
        ]

    imagemin:
      server:
        options:
          optimizationLevel: 0

        files:
          ".tmp/assets/img/icon.png": "<%= core.app %>/assets/img/icon.png"

      dist:
        options:
          optimizationLevel: 7

        files:
          "<%= core.dist %>/assets/img/icon.png": "<%= core.app %>/assets/img/icon.png"

    uglify:
      dist:
        options:
          banner: "<%= core.banner %>"
          report: "gzip"

        files: [
          expand: true
          cwd: "<%= core.dist %>/assets/js/"
          src: ["*.js", "!*.min.js"]
          dest: "<%= core.dist %>/assets/js/"
        ]

    copy:
      sync:
        files: [
          expand: true
          dot: true
          cwd: "<%= core.dist %>/"
          src: ["**"]
          dest: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= core.pkg.name %>/"
        ]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= core.dist %>/*"]
        ]

      sync:
        options:
          force: true

        files: [
          src: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= core.pkg.name %>/"
        ]

    concurrent:
      options:
        logConcurrentOutput: true

      server:
        tasks: ["less:server", "coffee:server", "imagemin:server"]

      dist:
        tasks: ["htmlmin", "cssmin", "imagemin:dist", "uglify"]

  grunt.registerTask "serve", ["connect:livereload", "concurrent:server", "autoprefixer:server", "watch"]
  grunt.registerTask "test", ["build"]
  grunt.registerTask "build", ["clean:dist", "coffeelint", "less:dist", "autoprefixer:dist", "coffee:dist", "concurrent:dist"]
  grunt.registerTask "sync", ["build", "clean:sync", "copy:sync"]
  grunt.registerTask "default", ["build"]
