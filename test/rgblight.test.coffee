
should = require "should"

{RGBLight} = require "../lib/enttec"



describe "RGB Light", ->

  light = new RGBLight
    name: "my light"
    address: 8

  it "can have name", ->
    should.equal light.name, "my light"


  it "can serialize to JSON", ->
    should.deepEqual light.toJSON(),
      name: "my light"
      type: "light"
      address: 8
      dmxChannels: 5
      dipConfig: "00010000"




