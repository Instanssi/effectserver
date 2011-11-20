
{jspack} = require "jspack"
{SerialPort} = require "serialport"



class RGBLight

  type: "lights"

  host: "enttec"

  constructor: (opts) ->
    @_buffer = new Buffer 5
    {@address} = opts


  set: (r, g, b) ->
    jspack.PackTo "<BBBBB", @_buffer, 0, [0, r, g, b, 0]

  getLength: -> @_buffer.length

  toBuffer: -> @_buffer

  getStart: -> parseInt @address, 10

  getEnd: -> @getStart() + @getLength()

  setOn: -> @set 255, 255, 255

  setOff: -> @set 0, 0, 0



class Enttec

  type: "enttec"

  _dmxHeaders:  new Buffer 4

  # Write magical dmx headers on class creation
  jspack.PackTo "<BBBB", @::_dmxHeaders, 0, [0x7e, 6, 0, 2]


  constructor: (opts) ->
    @_buffer = new Buffer 517
    @reset()
    @devices = []
    @serial = new SerialPort opts.path,
      baudrate: 57600


  add: (device) ->
    if device.host isnt @type
      throw new Error "Cannot add #{ device.type } device to #{ @type } host"

    for other in @devices
      if (device.getStart() < other.getStart() and other.getStart() < device.getEnd() or
         other.getStart() < device.getStart() and device.getStart() < other.getEnd() or
         other.getStart() is device.getStart() and device.getEnd() is other.getEnd())
        throw new Error "Device in #{ device.getStart() }...#{ device.getEnd() } clashes with device in  #{ other.getStart() }...#{ other.getEnd() }"

    if device not in @devices
      @devices.push device


  reset: ->
    # Format buffer with zeros
    for v, k in @_buffer
      @_buffer.write "\0", k


  writeAll: ->
    for device in @devices
      @write device

  write: (device) ->
    # Skip headers
    dmxPosition = device.address + @_dmxHeaders.length
    console.log "writing", device.toBuffer()

    device.toBuffer().copy @_buffer, dmxPosition, 0


  commit: ->
    @writeAll()

    # Make sure that headers are present
    @_dmxHeaders.copy @_buffer, 0, 0, @_dmxHeaders.length

    # dmx packet must always end with 0xe7
    jspack.PackTo "<B", @_buffer, @_buffer.length-1, [0xe7]

    @serial.write @_buffer

exports.Enttec = Enttec
exports.RGBLight = RGBLight


if require.main is module
  l = new RGBLight address: 7
  l.set 255, 255, 255
  console.log l._buffer.toString "base64"
  e = new Enttec path: "/dev/null"




