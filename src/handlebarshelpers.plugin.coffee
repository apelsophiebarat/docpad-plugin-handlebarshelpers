extendr = require('extendr')
pathUtil = require('path')
# Export Plugin
module.exports = (BasePlugin) ->
  HandlebarsPlugin = require('docpad-plugin-handlebars')(BasePlugin)

  # Define Plugin
  class HandlebarshelpersPlugin extends HandlebarsPlugin
    # Plugin name
    name: 'handlebarshelpers'

    constructor : ->
      super
      @registerHelpers()

    trace: (msg) -> @docpad.log('['+@name+'] '+msg) if @config.debug

    registerHelpers: () ->
      config = @config
      docpad = @docpad
      docpadConfig = docpad.getConfig()
      for helperRelativePath in config.helpersExtension
        helperPath = pathUtil.join(docpadConfig.rootPath, helperRelativePath)
        @trace('Load handlebars helpers module '+helperRelativePath)
        helperModule = require(helperPath)
        for name,helper of helperModule
          @trace('add helper '+name)
          @handlebars.registerHelper(name, helper)
