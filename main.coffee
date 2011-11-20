

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
        2:
          host: "enttec1"
          type: "rgb"
          address: 8

      smokes:
        0:
          host: "ent3tec1"
          type: "basicsmoke"
          address: 56

  manager.build()
  console.log manager.groups

