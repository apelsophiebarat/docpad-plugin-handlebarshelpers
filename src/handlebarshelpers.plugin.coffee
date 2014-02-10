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

    getHandlebarsPlugin: ->
      @handlebarsPlugin = @docpad.getPlugin('handlebars') unless @handlebarsPlugin?
      return @handlebarsPlugin

    getHandlebars: -> 
      @handlebars = @getHandlebarsPlugin().handlebars unless @handlebars?
      return @handlebars

    getPartialPlugin: ->
      @partialPlugin = @docpad.getPlugin('partials') unless @partialPlugin?
      return @partialPlugin

    helperAdapter = (fn) -> (context,options) ->
      #if context is implicit
      unless options?
        options=context
        context=@
      fn(context)

    partialAdapter = (templateData,name) -> (context,options) ->
      #if context is implicit
      unless options?
        options=context
        context=@
      templateData.partial(name,context)

    registerHelperFn: (name,helperFn) ->
      @trace("Register simple function as helper #{name}")
      @registerHelper name, helperAdapter(helperFn)

    registerHelper: (name,helper) ->
      @trace("Register helper #{name}")
      @getHandlebars().registerHelper name, helper

    registerPartial: (name,partial) ->
      @trace("Register partial #{name}")
      @getHandlebars().registerPartial(name,partial)

    registerDocpadPartial: (templateData,name) ->
      @registerPartial(name,partialAdapter(templateData,name))

    docpadReady: (opts,next) ->
      # Prepare
      docpad = @docpad
      {useTemplateDataFunctions,usePartials,extensions} = @getConfig()
      {rootPath} = docpad.getConfig()
      templateData = docpad.getTemplateData()
      # Check if handlebars plugin exist
      unless @getHandlebarsPlugin()?
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
            @registerHelper(name,helper)
          for own name,partial of partials
            @registerPartial(name, partial)
        catch error
          docpad.log 'error', "Error while loading extension #{extensionRelativePath} :#{error}"
          return next(error)
      
      # Register templateData functions has helpers
      if useTemplateDataFunctions
        @trace("load templateData functions has handlebars helpers")        
        for own name, helper of templateData when _.isFunction(helper)
          @registerHelperFn(name+"Helper", helper)

      # Register docpad partials has handlebars partials
      if usePartials and @getPartialPlugin()
        @trace("Load partials")
        {partialsPath,collectionName} = @getPartialPlugin().getConfig()
        # Load partials
        docpad.getCollection(collectionName).forEach (partialDocument) ->
          @registerDocpadPartial(templateData,partialDocument.name)

      return next()
      #chain
      next()
