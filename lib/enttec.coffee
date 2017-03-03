SerialPort = require "serialport"

addressToDip = (address) ->
  dip = address.toString(2).split("").reverse().join("")
  zeros = 8 - dip.length
  if zeros > 0
    for i in [0...zeros]
      dip += "0"
  dip

class RGBLight

  type: "light"

  host: "enttec"

  constructor: ({@name, @address}) ->
    @_buffer = new Buffer 5


  set: (r, g, b) ->
    @_buffer[0] = r
    @_buffer[1] = g
    @_buffer[2] = b
    @_buffer[3] = 255
    @_buffer[4] = 0

    # @_buffer[0] = 0
    # @_buffer[1] = r
    # @_buffer[2] = g
    # @_buffer[3] = b
    # @_buffer[4] = 0

  execute: (cmd, cb) ->
    # TODO: assert values
    {r, g, b} = cmd.cmd
    @set r, g, b

  getLength: -> @_buffer.length

  toBuffer: -> @_buffer

  getStart: -> parseInt @address, 10

  getEnd: -> @getStart() + @getLength()

  setOn: -> @set 255, 255, 255

  setOff: -> @set 0, 0, 0

  toJSON: ->
    address: @address
    type: @type
    name: @name
    dipConfig: addressToDip @address
    dmxChannels: @_buffer.length

class Enttec

  type: "enttec"

  # Write magical dmx headers on class creation
  _dmxHeaders:  new Buffer [0x7e, 6, 0, 2]


  constructor: (opts) ->
    # buffer for header + 512-byte payload + terminator
    @_buffer = new Buffer 517
    @reset()
    @devices = []
    if opts.path
      @serial = new SerialPort opts.path,
        baudrate: 57600


  add: (device) ->
    if device.host isnt @type
      throw new Error "Cannot add #{ device.type } device to #{ @type } host"

    for other in @devices

      startOverLaps = device.getStart() < other.getStart() and other.getStart() < device.getEnd()
      endOverLaps = other.getStart() < device.getStart() and device.getStart() < other.getEnd()
      onTop = other.getStart() is device.getStart() and device.getEnd() is other.getEnd()

      if startOverLaps or endOverLaps or onTop
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

    device.toBuffer().copy @_buffer, dmxPosition, 0


  commit: ->
    @writeAll()

    # Make sure that headers are present
    @_dmxHeaders.copy @_buffer, 0, 0, @_dmxHeaders.length

    # dmx packet must always end with 0xe7
    @_buffer[@_buffer.length-1]  = 0xe7

    if @serial
      @serial.write @_buffer

exports.Enttec = Enttec
exports.RGBLight = RGBLight


if require.main is module
  l = new RGBLight address: 7
  l.set 255, 255, 255
  console.log l._buffer.toString "base64"
  e = new Enttec path: null




