extendr = require 'extendr'
pathUtil = require 'path'
_ = require 'underscore'

# Export Plugin
module.exports = (BasePlugin) ->

  # Define Plugin
  class HandlebarshelpersPlugin extends BasePlugin
    # Plugin name
    name: 'handlebarshelpers'

    config:
      debug: false
      useTemplateDataFunctions: false
      usePartials: false
      extensions: []

    trace: (msg) -> 
      logLevel = 
        if @getConfig().debug then 'info'
        else 'debug'
      @docpad.log logLevel, "[#{@name}] #{msg}"

    docpadReady: (opts,next) ->
      # Prepare
      docpad = @docpad
      {useTemplateDataFunctions,usePartials,extensions} = @getConfig()
      {rootPath} = docpad.getConfig()
      templateData = docpad.getTemplateData()
      # Check if handlebars plugin exist
      handlebarsPlugin = docpad.getPlugin('handlebars')
      unless handlebarsPlugin?
        docpad.log 'warn', 'handlebars plugin not installed'
        return

      # Register handlebars extensions
      extensions = [extensions] unless _.isArray(extensions)
      for extensionRelativePath in extensions
        extensionPath = pathUtil.join(rootPath, extensionRelativePath)
        @trace("Load handlebars extension module #{extensionRelativePath}")
        try
          {helpers,partials} = require(extensionPath)
          for own name,helper of helpers
            @trace("Register helper #{name}")
            handlebarsPlugin.handlebars.registerHelper(name, helper)
          for own name,partial of partials
            @trace("Register partial #{name}")
            handlebarsPlugin.handlebars.registerPartial(name, partial)
        catch error
          docpad.log 'error', "Error while loading extension #{helperRelativePath} :#{error}"
          return next(error)
      
      # Register templateData functions has helpers
      if useTemplateDataFunctions
        @trace("load templateData functions has handlebars helpers")        
        for own name, helper of templateData when _.isFunction(helper)
          @trace("Register templateData helper function #{name}")
          handlebarsPlugin.handlebars.registerHelper(name, helper)

      # Register docpad partials has handlebars partials
      partialsPlugin = docpad.getPlugin('partials')
      if usePartials and partialsPlugin?
        @trace("Load partials")
        {partialsPath,collectionName} = partialsPlugin.getConfig()
        # Load partials
        newPartialAdapter = (partialName) -> 
          (context, options) -> 
            templateData.partial(partialName,context)
        docpad.getCollection(collectionName).forEach (partialDocument) ->
          name = partialDocument.name
          @trace("Register partial #{name}")
          handlebarsPlugin.handlebars.registerPartial name, newPartialAdapter(name)

      return next()








      #chain
      next()
