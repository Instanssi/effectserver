

dgram = require('dgram')


class EffectRecorder

  constructor: ->
    @program = []


  custom: (i, r, g, b) ->
    @program.push
      cmd: "color"
      id: i
      r: r
      g: g
      b: b

  red: (i) -> @custom i, 255, 0, 0

  green: (i) -> @custom i, 0, 255, 0

  blue: (i) -> @custom i, 0, 0, 255

  pause: (time) ->
    @program.push
      cmd: "pause"
      time: time


class EffectPlayer

  constructor: ({@program, @host, @port}) ->
    @position = @program.length
    @udp = dgram.createSocket "udp4"

    @buf = new Buffer [
      1 # spec version
      , 1 # Type. 1 means light
      , 0 # light id
      , 0 # Light type. 0 means rgb
      , 0
      , 0
      , 0
    ]

  next: ->
    @position = (@position + 1) % @program.length
    a = @program[@position]

  playColor: (color) ->
    @buf[2] = color.id
    @buf[4] = color.r
    @buf[5] = color.g
    @buf[6] = color.b
    @udp.send @buf, 0, @buf.length, 9909, "127.0.0.1"

  loop: =>

    action = @next()
    pause = 0


    if action.cmd is "color"
      @playColor action

    if action.cmd is "pause"
      pause = action.time

    setTimeout @loop, pause


if require.main is module

  recorder = new EffectRecorder

  for i in [0..6]
    recorder.red i
    recorder.pause 200
    recorder.green i
    recorder.pause 200

  player = new EffectPlayer
    host: "127.0.0.1"
    port: 9909
    program: recorder.program

  player.loop()


