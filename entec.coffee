
fs = require "fs"
{jspack} = require "jspack"
_  = require 'underscore'

console.log new Buffer jspack.Pack "<BBBB", [0x7e, 6, 0, 2]

devicePath = process.argv[2] or "/dev/serial/by-id/usb-FTDI_FT245R_USB_FIFO_ENP9D7H7-if00-port0"

{SerialPort} = require "serialport",
    baudrate: 57600

device = new SerialPort devicePath

fs.readFile __dirname + "/on.dat", (err, data) ->
  throw err if err
  console.log "example", data.length, data
  # device.write data

  e = new Entec device

  # e.setLamp 2, 0, 0, 0
  e.setLamp 2, 10, 255, 0
  e.commit()
  # console.log "EQ", _.isEqual e.buffer, data




class Entec


  constructor: (@device) ->

    @buffer = new Buffer 517

    # Format buffer with zeros
    for v, k in @buffer
      @buffer.write "\0", k, "utf8"


  setLamp: (dmxPOS, r, g, b) ->
    jspack.PackTo "<BBBBB", @buffer, dmxPOS+4, [0, r, g, b, 0]

  commit: ->
    jspack.PackTo "<BBBB", @buffer, 0, [0x7e, 6, 0, 2]
    jspack.PackTo "<B", @buffer, @buffer.length-1, [0xe7]
    console.log "mine", @buffer.length, @buffer
    @device.write @buffer




