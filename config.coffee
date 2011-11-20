
config =
  hosts:
    enttec1:
      path: "/dev/serial/by-id/usb-FTDI_FT245R_USB_FIFO_ENP9D7H7-if00-port0"
      type: "enttec"
    enttec2:
      path: "/dev/serial/by-id/usb-FTDI_FT245R_USB_FIFO_ENP9D7H7-if00-port1"
      type: "enttec"
    arduino1:
      path: "/dev/serial/arduino"
      type: "arduino"

  mapping:

    lights:
      0:
        host: "enttec2"
        type: "rgb"
        address: 8
      2:
        host: "enttec2"
        type: "hsv"
        address: 16
      3:
        host: "arduino1"
        type: "led"
        ledNumber: 2
      4:
        host: "group"
        members: [ 0, 2 ]

    smokes:
      0:
        host: "enttec1"
        type: "basicsmoke"
        address: 56
