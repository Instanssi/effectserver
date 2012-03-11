###
#
# Node.js & CoffeeScript
#
####



dgram = require('dgram')

tty = require('tty')
process.stdin.resume()
tty.setRawMode(true)


randInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min


class EffectClient

  constructor: ({@min, @max, @nick, @ip, @port}) ->
    @client = dgram.createSocket("udp4")
    @reset()

  getRandId: -> randInt @min, @max

  reset: ->
    @packet = [ 1 ]
    @packet.push 0
    for c in @nick
      @packet.push c.charCodeAt 0
    @packet.push 0

  setAll: (r, g, b) ->
    for i in [@min..@max]
      @set i, r, g, b

  set: (i, r, g, b) ->
    @packet.push 1
    @packet.push i
    @packet.push 0

    @packet.push r
    @packet.push g
    @packet.push b

  send: ->
    buf = new Buffer @packet
    @client.send buf, 0, buf.length, @port, @ip
    @reset()



class Player

  constructor: (@client) ->

  loop: (program) ->
    @stop()
    @program = program
    @pos = @program.length
    @tick()

  stop: ->
    clearTimeout @timeout if @timeout
    @program = null


  tick: =>
    if not @program
      return

    @pos = (@pos + 1) % @program.length

    action = @program[@pos]

    if typeof action is "number"
      @client.send()
      @timeout = setTimeout @tick, action
      return

    if Array.isArray action
      @client.set action...
      process.nextTick @tick
      return


    throw new Error "Bad action"


  createProgram: (cb) ->
    program = []

    next = (time=0) -> program.push time

    set = (i, r, g, b) ->
      if typeof r is "object"
        {r,g,b} = r
      program.push [i, r, g, b]

    all = (args...) =>
      for i in [@client.min..@client.max]
        set i, args...

    cb set, all, next, program

    return program






main = ->

  client = new EffectClient
    min: 0
    max: 38
    nick: process.env.TAG or "epe"
    ip: process.argv[2] or "localhost"
    port: 9909


  player = new Player client

  RED =
    r: 255
    g: 0
    b: 0
  GREEN =
    r: 0
    g: 255
    b: 0
  BLUE =
    r: 0
    g: 0
    b: 255
  BLACK =
    r: 0
    g: 0
    b: 0
  WHITE =
    r: 255
    g: 255
    b: 255

  keyboardKeys =

    o:
      name: "OFF"
      program: player.createProgram (set, all, next) ->
        all BLACK
        next 1000

    p:
      name: "ON"
      program: player.createProgram (set, all, next) ->
        all WHITE
        next 1000

    r:
      name: "round red"
      program: player.createProgram (set, all, next) ->

        all BLACK
        len = 10

        for i in [client.min..client.max]
          for j in [0..len]
            set i-j, BLACK

          for j in [0..len]
            set i+j, RED

          next 20


    b:
      name: "blue fade"
      program: player.createProgram (set, all, next) ->

        all 10, 10, 10
        next 0

        for i in [10..255] by 5
          all 0, 0, i
          next 30

        for i in [10..255] by 5
          all 0, 0, 255-i
          next 30

        next 30


    h:
      name: "fast green blue"
      program: player.createProgram (set, all, next) ->
        all GREEN
        next 100
        all BLUE
        next 100

    j:
      name: "flash red"
      program: player.createProgram (set, all, next) ->
        all BLACK
        next 100
        all RED
        next 100

    l:
      name: "red sides"
      program: player.createProgram (set, all, next) ->

        for i in [0..38/2]
          set i, BLACK

        for i in [38/2..38]
          set i, RED

        next 300

        for i in [0..38/2]
          set i, RED

        for i in [38/2..38]
          set i, BLACK

        next 300


    n:
      name: "roud blue"
      program: player.createProgram (set, all, next) ->

        all BLACK

        for i in [client.min..client.max]
          set i-1, BLACK
          set i-2, BLACK
          set i, BLUE
          set i+1, BLUE
          set i+2, BLUE
          next 100




  printHelp = ->

    console.log ""
    for k, ob of keyboardKeys
      console.log "#{ k }: #{ ob.name }"
    console.log ""


  printHelp()
  process.stdin.on 'keypress', (char, key) ->


    if char.charCodeAt(0) is 27 # esc
      process.exit 0
    if key?.name is "c" and key.ctrl
      process.exit 0


    if char is "s" # stop
      console.log "Stopping"
      player.stop()
      return

    printHelp()

    if ob = keyboardKeys[char]
      console.log "Playing", ob.name
      player.loop ob.program
    else
      console.log "Unkown program #{ char }"


if require.main is module
  main()
