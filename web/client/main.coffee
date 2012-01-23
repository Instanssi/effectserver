
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
    console.log "setting bg to #{ JSON.stringify cmd }", @$el



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

  socket.on "cmds", (msg, a) ->
    for lightpacket in msg.cmds
      l = lights[lightpacket.id]
      l.apply lightpacket.cmd
