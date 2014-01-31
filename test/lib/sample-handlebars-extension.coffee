module.exports =
  
  helpers:
    capitalize: (content,options) ->
      content.charAt(0).toUpperCase() + content.slice(1)
    useContextInExtension: (content,options) ->
      "this is #{this.document.title}"

  partials:
    titleInExtension: '<h3>{{document.title}}</h3>'
