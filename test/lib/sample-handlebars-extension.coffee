module.exports =
  helpers:
    capitalize: (content) ->
      content.charAt(0).toUpperCase() + content.slice(1)
  partials:
    titlePartial: '<h3>{{document.title}}</h3>'
