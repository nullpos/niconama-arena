module.exports = (grunt) ->
  # Show elapsed time at the end.
  require('time-grunt')(grunt)
  # Load all grunt tasks.
  require('load-grunt-config')(grunt)

  srcCoffeeDir = 'src/coffee/'
  destJsDir = 'contents/js/'
  compressJsDir = 'contents/compress/'

  srcLessDir = 'src/less/'
  destCssDir = 'contents/css/'

  # Specify relative path from "src/coffee/".
  bare_list = [
    'common.coffee'
  ]
  reTrimCwd = new RegExp '^src/coffee/'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    meta:
      banner: '/*! <%= pkg.name %> - v<%= pkg.version %> -' +
        ' <%= grunt.template.today("yyyy-mm-dd") %>\n' +
        ' * <%= pkg.repository.url %>\n' +
        ' * Copyright (c) <%= grunt.template.today("yyyy") %>' +
        ' Yonchu; Licensed MIT\n' +
        ' */'

    coffee:
      compile:
        options:
          sourceMap: false
        files: [
          expand: true,
          cwd: srcCoffeeDir,
          src: ['**/*.coffee'],
          dest: destJsDir,
          ext: '.js'
          filter: (path) ->
            noCwdPath = path.replace reTrimCwd, ''
            return not (noCwdPath in bare_list)
        ]
      compileBare:
        options:
          bare: true,
          sourceMap: false
        files: [
          expand: true,
          cwd: srcCoffeeDir,
          src: bare_list,
          dest: destJsDir,
          ext: '.js'
        ]

    less:
      development:
        files: [
          expand: true,
          cwd: srcLessDir,
          src: ['**/*.less'],
          dest: destCssDir,
          ext: '.css'
        ]
      production:
        options:
          yuicompress: true
        files: [
          expand: true,
          cwd: srcLessDir,
          src: ['**/*.less'],
          dest: destCssDir,
          ext: '.css'
        ]

    uglify:
      compress_target:
        options:
          sourceMap: (fileName) ->
            fileName.replace /\.js$/, '.js.map'
          banner: '<%= meta.banner %>'
        files: [
          expand: true,
          cwd: destJsDir,
          src: ['**/*.js'],
          dest: compressJsDir,
          filter: (path) ->
            return not (path.match 'js/lib/vendor/')
        ]

    regarde:
      coffee:
        files: ["#{srcCoffeeDir}**/*.coffee"],
        tasks: ['coffee']
      less:
        files: ["#{srcLessDir}**/*.less"],
        tasks: ['less:development']

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      all:
        files:
          src: ["#{srcCoffeeDir}**/*.coffee"]

    jsonlint:
      all:
        files:
          src: [
            '*.json', '.bowerrc', '.jshintrc',
            'contents/manifest.json'
          ]

    jshint:
      options:
        jshintrc: '.jshintrc'
      all:
        src: [
          "#{destJsDir}**/*.js"
        ],
        filter: (path) ->
          return false if path.match '/lib/'
          return false if path is 'contents/js/popup-tmpl.js'
          return true

    clean:
      js:
        src: [
          "#{destJsDir}**/*.js",
        ],
        filter: (path) ->
          return not (path.match '/lib/')
      jsmap:
        src: [
          "#{destJsDir}**/*.map"
        ],
        filter: (path) ->
          return not (path.match '/lib/vendor/')
      compress:
        src: [
          "#{compressJsDir}**/*.js",
          "#{compressJsDir}**/*.map",
          "#{compressJsDir}lib"
        ]
      css:
        src: [
          "#{destCssDir}**/*.css"
        ]

  # Rename
  # grunt.renameTask('regarde', 'watch');

  # Register custom tasks.
  grunt.registerTask 'watch', ['regarde']
  grunt.registerTask 'build', ['coffeelint', 'jsonlint', 'coffee', 'less:development']
  grunt.registerTask 'release', ['coffeelint', 'jsonlint', 'coffee', 'uglify', 'less:production']

  # Register default task.
  grunt.registerTask 'default', ['build']
