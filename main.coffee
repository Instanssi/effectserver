
dgram = require "dgram"
util = require "util"
{EventEmitter} = require('events')

{EffectManager} = require "./effectmanager"

{parse} = require "./packetparser"

udpPort = 9909

manager = new EffectManager
  hosts:
    enttec1:
      path: "/dev/serial/by-id/usb-FTDI_FT245R_USB_FIFO_ENP9D7H7-if00-port0"
      type: "enttec"
    # enttec2:
    #   path: "/dev/serial/by-id/usb-FTDI_USB__-__Serial-if00-port0"
    #   type: "enttec"
  mapping:
    light:
      0:
        host: "enttec1"
        type: "rgb"
        address: 8
      # 1:
      #   host: "enttec2"
      #   type: "rgb"
      #   address: 8


manager.build()

udbserver = dgram.createSocket("udp4")

websocket = new EventEmitter

websocket.on "error", (user, msg) ->
  console.log "#{ user }: #{ msg }"


udbserver.on "message", (packet, rinfo) ->

  console.log "got msg"
  user = rinfo.address

  try
    cmds = parse packet
  catch e
    websocket.emit "error", user, "Failed to parse #{util.inspect packet} because: #{ e }"
    return

  tag = "anonymous"

  for cmd in cmds

    if cmd.tag
      tag = cmd
      continue

    {r, g, b} = cmd.cmd

    deviceGroup = manager.groups[cmd.deviceType]
    if not deviceGroup
      websocket.emit "error", user, "Unknown device group #{ cmd.deviceType }"
      continue

    device = deviceGroup.devices[cmd.id]
    if not device
      websocket.emit "error", user, "Unkown virtual id #{ cmd.id }"
      continue

    device.set r, g, b


  manager.commitAll()



udbserver.on "listening", ->
  console.log "Effect Server is now listening on #{ udpPort }"

udbserver.bind udpPort



if require.main is module

  # console.log "light0", manager.groups.lights.devices[0].set

  for k, l of manager.groups.light.devices
    l.set 255, 255, 255

  manager.commitAll()

