
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

    if typeof r is "object"
      {r,g,b} = r

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



client = new EffectClient
  min: 0
  max: 38
  nick: process.env.TAG or "epe"
  ip: process.argv[2] or "localhost"
  port: 9909


extend = (a) ->
  a.sleep = (time) -> @push time
  a.set = (i, r, g, b) -> @push [i, r, g, b]
  a.all = (r, g, b) ->
    for i in [client.min..client.max]
      @push [i, r, g, b]
  return a

RED = [255, 0, 0]
GREEN = [0, 255, 0]
BLUE = [0, 0, 255]
BLACK = [0, 0, 0]
WHITE = [255, 255, 255]

mapping =

  o: do ->
    p = extend []
    p.all BLACK...
    p.sleep 1000
    return p


  p: do ->
    p = extend []
    p.all WHITE...
    p.sleep 1000
    return p

  r: do ->
    p = extend []

    p.all BLACK
    len = 10

    for i in [client.min..client.max]
      for j in [0..len]
        p.set i-j, BLACK...

      for j in [0..len]
        p.set i+j, RED...

      p.sleep 20

    return p

  b: do ->
    p = extend []

    p.all 10, 10, 10
    p.sleep 0

    for i in [10..255] by 5
      p.all 0, 0, i
      p.sleep 30

    for i in [10..255] by 5
      p.all 0, 0, 255-i
      p.sleep 30

    p.sleep 30

    return p


  h: do ->
    p = extend []
    p.all GREEN...
    p.sleep 100
    p.all BLUE...
    p.sleep 100
    return p

  j: do ->
    p = extend []
    p.all BLACK...
    p.sleep 100
    p.all RED...
    p.sleep 100
    return p

  l: do ->
    p = extend []
    for i in [0..38/2]
      p.set i, BLACK...

    for i in [38/2..38]
      p.set i, RED...

    p.sleep 300

    for i in [0..38/2]
      p.set i, RED...

    for i in [38/2..38]
      p.set i, BLACK...

    p.sleep 300

    return p

  n: do ->
    p = extend []

    p.all BLACK

    for i in [client.min..client.max]
      p.set i-1, BLACK...
      p.set i-2, BLACK...
      p.set i, BLUE...
      p.set i+1, BLUE...
      p.set i+2, BLUE...
      p.sleep 100



    return p


player = new Player client


process.stdin.on 'keypress', (char, key) ->
  if char.charCodeAt(0) is 27 # esc
    process.exit 0

  return if not key # Ignore bad keys

  console.log ("#{ k }: #{ p.length }" for k, p of mapping).join ", "

  if key.name is "s" # stop
    console.log "Stopping"
    player.stop()
    return

  if program = mapping[key.name]
    console.log "Playing", key.name
    player.loop program
  else
    console.log "Unkown program #{ char }"


