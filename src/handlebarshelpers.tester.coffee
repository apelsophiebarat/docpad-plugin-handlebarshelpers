debug = false
logLevel = if debug then 6 else 5
# Export Plugin Tester
module.exports = (testers) ->
  # Define Plugin Tester
  class HandlebarshelpersPluginTester extends testers.RendererTester
    # Configuration
    config:
      removeWhitespace: false

    docpadConfig:
      templateData:
        hello: (name) -> "Hello #{name} !"
      
      plugins:
        handlebarshelpers:
          debug:debug
          extensions: './lib/sample-handlebars-extension'

      enabledPlugins:
        'marked': true
        'eco': false
        'handlebars': true
      
      logLevel: logLevel #6 #for info #7 #for debug
