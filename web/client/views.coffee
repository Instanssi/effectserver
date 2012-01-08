

views = NS "ES.views"


class Log extends Backbone.View

  constructor: (@opts) ->
    super

    @messages = []
    @dirty = false

    setInterval =>
      @render() if @dirty
    , 20


  info: (msg) ->
    @_log "<div class=error >#{ msg }</div>"

  error: (msg) ->
    @_log "<div class=info >#{ msg }</div>"

  _log: (msg) ->
    @messages.unshift msg

    if @messages.length > 100
      @messages.pop()

    @dirty = true

  render: ->
    html = ""
    for msg in @messages
      html += msg
    @el.innerHTML = html
    console.log html
    @dirty = false

