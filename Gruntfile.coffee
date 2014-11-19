"use strict"
LIVERELOAD_PORT = 35728
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # Load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # Project configurations
  grunt.initConfig
    config:
      pkg: grunt.file.readJSON("package.json")
      app: "app"
      dist: "dist"
      banner: do ->
        banner = "<!--\n"
        banner += " © <%= config.pkg.author %>.\n\n"
        banner += " <%= config.pkg.name %> - v<%= config.pkg.version %> (<%= grunt.template.today('mm-dd-yyyy') %>)\n"
        banner += " <%= config.pkg.homepage %>\n"
        banner += " <%= config.pkg.license %>\n"
        banner += " -->"
        banner

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
          src: ["<%= config.app %>/assets/coffee/app.coffee"]

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
        files: ["<%= config.app %>/assets/less/app.less"]
        tasks: ["less:server", "autoprefixer:server"]

      livereload:
        options:
          livereload: LIVERELOAD_PORT

        files: ["<%= config.app %>/*.html", "{.tmp,<%= config.app %>}/assets/css/{,*/}*.css", "{.tmp,<%= config.app %>}/assets/js/{,*/}*.js", "<%= config.app %>/assets/img/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"]

    coffee:
      server:
        options:
          sourceMap: true

        files:
          ".tmp/assets/js/app.js": ["<%= config.app %>/assets/coffee/app.coffee"]

      dist:
        files:
          "<%= config.dist %>/assets/js/app.js": ["<%= config.app %>/assets/coffee/app.coffee"]

    less:
      server:
        options:
          strictMath: true
          sourceMap: true
          outputSourceFiles: true
          sourceMapURL: "app.css.map"
          sourceMapFilename: ".tmp/assets/css/app.css.map"

        src: ["<%= config.app %>/assets/less/app.less"]
        dest: ".tmp/assets/css/app.css"

      dist:
        src: ["<%= less.server.src %>"]
        dest: "<%= config.dist %>/assets/css/app.css"

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
          cwd: "<%= config.app %>"
          src: "**/*.html"
          dest: "<%= config.dist %>/"
        ]

    cssmin:
      dist:
        options:
          report: "gzip"

        files: [
          expand: true
          cwd: "<%= config.dist %>/assets/css/"
          src: ["*.css", "!*.min.css"]
          dest: "<%= config.dist %>/assets/css/"
        ]

    uglify:
      dist:
        options:
          report: "gzip"

        files: [
          expand: true
          cwd: "<%= config.dist %>/assets/js/"
          src: ["*.js", "!*.min.js"]
          dest: "<%= config.dist %>/assets/js/"
        ]

    smoosher:
      options:
        jsDir: "<%= config.dist %>"
        cssDir: "<%= config.dist %>"

      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: "**/*.html"
          dest: "<%= config.dist %>/"
        ]

    usebanner:
      options:
        position: "bottom"
        banner: "<%= config.banner %>"

      dist:
        files:
          src: ["<%= config.dist %>/**/*.html"]

    copy:
      sync:
        files: [
          expand: true
          dot: true
          cwd: "<%= config.dist %>/"
          src: ["**"]
          dest: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= config.pkg.name %>/"
        ]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= config.dist %>/*"]
        ]

      postDist:
        src: ["<%= config.dist %>/assets/"]

      sync:
        options:
          force: true

        files: [
          src: "/Users/sparanoid/Dropbox/Sites/sparanoid.com/lab/<%= config.pkg.name %>/"
        ]

    concurrent:
      options:
        logConcurrentOutput: true

      server:
        tasks: ["less:server", "coffee:server"]

      dist:
        tasks: ["htmlmin", "cssmin", "uglify"]

  grunt.registerTask "serve", [
    "connect:livereload"
    "concurrent:server"
    "autoprefixer:server"
    "watch"
  ]

  grunt.registerTask "test", [
    "build"
  ]

  grunt.registerTask "build", [
    "clean:dist"
    "coffeelint"
    "less:dist"
    "autoprefixer:dist"
    "coffee:dist"
    "concurrent:dist"
    "smoosher"
    "usebanner"
    "clean:postDist"
  ]

  grunt.registerTask "sync", [
    "build"
    "clean:sync"
    "copy:sync"
  ]

  grunt.registerTask "default", [
    "build"
  ]
