module.exports =
  todos_apps:
    output: '../js'
    directories: [
      'app-todos-classic/src',
      'app-todos-extended/src'
    ]

  tests:
    directories: [
      'test/todos-classic'
      'test/todos-extended'
    ]
    _build:
      output: 'build'
    _test:
      command: 'phantomjs'
      runner: 'phantomjs-qunit-runner.js'
      files: '**/*.html'

  _postinstall:
    commands: [
      'cp -v backbone-relational vendor/backbone-relational.js'
      'cp -v lodash vendor/lodash.js'

      # todos-classic
      'cp -v knockback/knockback-core-stack.min.js app-todos-classic/js/lib/knockback-core-stack.min.js'
      'cp vendor/backbone.localStorage-min.js app-todos-classic/js/lib/backbone.localStorage-min.js'

      # todos-extended
      'cp -v knockback/knockback-full-stack.min.js app-todos-extended/js/lib/knockback-full-stack.min.js'
      'cp -v backbone-modelref/backbone-modelref.min.js app-todos-extended/js/lib/backbone-modelref.min.js'
      'cp vendor/backbone.localStorage-min.js app-todos-extended/js/lib/backbone.localStorage-min.js'
      'cp vendor/mColorPicker.min.js app-todos-extended/js/lib/mColorPicker.min.js'
      'cp -r vendor/globalize app-todos-extended/js/lib/globalize'
    ]