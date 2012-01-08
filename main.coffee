
dgram = require "dgram"
util = require "util"

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





udbserver.on "listening", ->
  console.log "Effect Server is now listening on #{ udpPort }"

udbserver.bind udpPort



if require.main is module

  # console.log "light0", manager.groups.lights.devices[0].set

  for k, l of manager.groups.light.devices
    l.set 255, 255, 255

  manager.commitAll()

