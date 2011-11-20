

{EffectManager} = require "./effectmanager"


if require.main is module
  manager = new EffectManager
    hosts:
      enttec1:
        path: "/dev/serial/by-id/usb-FTDI_FT245R_USB_FIFO_ENP9D7H7-if00-port0"
        type: "enttec"
    mapping:
      lights:
        0:
          host: "enttec1"
          type: "rgb"
          address: 2
        1:
          host: "enttec1"
          type: "rgb"
          address: 8


  manager.build()
  console.log "groups:", manager.groups

  # console.log "light0", manager.groups.lights.devices[0].set

  manager.groups.lights.devices[0].set 255, 0, 0
  manager.groups.lights.devices[1].set 255, 0, 0

  manager.commitAll()

