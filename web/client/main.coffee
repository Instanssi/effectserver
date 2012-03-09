
class LightSimulator extends Backbone.View

  className: "lightSimulator"

  constructor: ({@info}) ->
    super
    @$el = $ @el

    source  = $("#lightTemplate").html()
    @template = Handlebars.compile source

  render: ->
    @$el.html @template @info
    @valueDisplay = @$(".rgbValue").get 0

  apply: (cmd) ->
    cssValue = "rgb(#{ cmd.r }, #{ cmd.g }, #{ cmd.b })"
    @$el.css "background-color", cssValue
    @valueDisplay.innerHTML = cssValue


class Log extends Backbone.View

  constructor: (@opts) ->
    super
    @$el = $ @el
    @messages = []
    @dirty = false

    setInterval =>
      @render() if @dirty
    , 20


  log: (msg) ->
    @messages.unshift msg

    if @messages.length > 100
      @messages.pop()

    @dirty = true

  render: ->
    html = ""
    for msg in @messages
      html += "<p>#{ msg }</p>"
    @el.innerHTML = html
    console.log html
    @dirty = false


prettifyMsg = (msg) ->
  "#{ msg.tag } (#{ msg.address })"

$ ->
  lights = {}
  devices = $ ".devices"

  $.get "/config.json", (data) ->
    for id, info of data.light
      info.id = id
      l = lights[id] = new LightSimulator info: info
      l.render()
      devices.append l.el


  socket = io.connect()
  socket.on "connect", ->
    console.log "Effect Server Connected"

  logInfo = new Log
    el: ".info"

  logError = new Log
    el: ".error"

  socket.on "parseError", (msg) ->
    logError.log "#{ prettifyMsg msg }: Parse error: #{ msg.error }"

  socket.on "cmds", (msg, a) ->
    for lightpacket in msg.cmds
      if l = lights[lightpacket.id]
        l.apply lightpacket.cmd
        logInfo.log "#{ prettifyMsg msg }: #{ JSON.stringify lightpacket }"
      else
        logError.log "#{ prettifyMsg msg }: Unkown light id #{ lightpacket.id }"



