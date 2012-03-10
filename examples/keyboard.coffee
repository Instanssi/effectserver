###
# Instanssi 2012 Keyboard light controller.
# Execute with Node.js and CoffeeScript
###



tty = require('tty')
dgram = require('dgram')

process.stdin.resume()
tty.setRawMode(true)


class RGB

  constructor: (@nick, @ip, @port) ->
    @client = dgram.createSocket("udp4")
    @reset()

  reset: ->
    @packet = [ 1 ]
    @packet.push 0
    for c in @nick
      @packet.push c.charCodeAt 0
    @packet.push 0

  set: (i, r, g, b) ->
    @packet.push 1
    @packet.push i
    @packet.push 0
    @packet.push r
    @packet.push g
    @packet.push b

  send: ->
    buf = new Buffer @packet
    console.log buf
    @client.send buf, 0, buf.length, @port, @ip
    @reset()


mapping =
  q: 0
  w: 1
  e: 2
  r: 3
  t: 4
  y: 5
  u: 6
  i: 7
  o: 8
  p: 9
  å: 10
  a: 11
  s: 12
  d: 13
  f: 14
  g: 15
  h: 16
  j: 17
  k: 18
  l: 19
  ö: 20
  ä: 21
  z: 22
  x: 23
  c: 24
  v: 25
  b: 26
  n: 27
  m: 28

rgb = new RGB "esa", "192.168.10.1", 9909

rgb.set 1, 255, 0, 0
console.log rgb.packet

rgb.send()

process.stdin.on 'keypress', (char, key) ->
  return if not key

  code = char.charCodeAt(0)
  if  code is 27 # esc
    process.exit 0

  console.log key

  if id = mapping[key.name]

    if key.shift
      rgb.set id, 255, 0, 0
    else if key.ctrl
      rgb.set id, 0, 255, 0
    else
      rgb.set id, 0, 0, 255

    rgb.send()
    setTimeout ->
      rgb.set id, 0, 0, 0
      rgb.send()
    , 100

  else
    console.error "Unkown key", char, code



