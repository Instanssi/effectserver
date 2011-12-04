
should = require "should"

{parse} = require "../packetparser"


describe "packet parser", ->

  it "can parse single packet", ->

    lightPacket = new Buffer [
      1 # spec version
      , 1 # Type. 1 means light
      , 1 # light id
      , 0 # Light type. 0 means rgb
      , 0   # R
      , 255 # G
      , 0   # B
    ]

    cmds = parse lightPacket

    expexted = [
      deviceType: "light"
      id: 1
      cmd:
        lightType: "rgb"
        r: 0
        g: 255
        b: 0

    ]

    should.deepEqual cmds, expexted



  it "can parse two light packets from single udp-packet", ->

    lightPacket = new Buffer [
      1 # spec version
      , 1 # Type. 1 means light
      , 1 # light id
      , 0 # Light type. 0 means rgb
      , 0 # R
      , 255 # G
      , 0 #B

      , 1 # Type. 1 means light
      , 2 # light id
      , 0 # Light type. 0 means rgb
      , 0 # R
      , 0 # G
      , 255 #B
    ]

    cmds = parse lightPacket

    expexted = [
      deviceType: "light"
      id: 1
      cmd:
        lightType: "rgb"
        r: 0
        g: 255
        b: 0
    ,
      deviceType: "light"
      id: 2
      cmd:
        lightType: "rgb"
        r: 0
        g: 0
        b: 255
    ]

    console.log "expexted:", expexted, "got:", cmds
    should.deepEqual cmds, expexted


  it "can parse three light packets from single udp-packet", ->

    lightPacket = new Buffer [
      1 # spec version

      , 1 # Type. 1 means light
      , 1 # light id
      , 0 # Light type. 0 means rgb
      , 0 # R
      , 255 # G
      , 0 #B

      , 1 # Type. 1 means light
      , 2 # light id
      , 0 # Light type. 0 means rgb
      , 0 # R
      , 0 # G
      , 255 #B

      , 1 # Type. 1 means light
      , 3 # light id
      , 0 # Light type. 0 means rgb
      , 255 # R
      , 0 # G
      , 255 #B
    ]

    cmds = parse lightPacket

    expexted = [
      deviceType: "light"
      id: 1
      cmd:
        lightType: "rgb"
        r: 0
        g: 255
        b: 0
    ,
      deviceType: "light"
      id: 2
      cmd:
        lightType: "rgb"
        r: 0
        g: 0
        b: 255
    ,
      deviceType: "light"
      id: 3
      cmd:
        lightType: "rgb"
        r: 255
        g: 0
        b: 255
    ]

    console.log "expexted:", expexted, "got:", cmds
    should.deepEqual cmds, expexted
