
assert = require "assert"
_  = require 'underscore'
enttec = require "../lib/enttec"


dmxHeaders = new Buffer [0x7e, 6, 0, 2]


describe "RGB Light", ->
  light = new enttec.RGBLight address: 8
  light.set 0, 255, 0

  it "Has length of 5",  ->
    assert.equal light.getLength(), 5

  it "is green",  ->
    assert.deepEqual light.toBuffer(), new Buffer [0, 255, 0, 255, 0]


describe "Enttec host buffer", ->
  data = null

  beforeEach (done) ->
    host = new enttec.Enttec path: null
    host.serial = write: (data2) ->
      data = data2
      done()
    host.commit()

  it "generates headers matching the DMX512 specs", ->
    assert.deepEqual data.slice(0, dmxHeaders.length), dmxHeaders

  it "ends the buffer in the terminator character", ->
    assert.equal data[data.length-1], 0xe7


describe "Enttec buffer output for RGB lights", ->
  data = null

  beforeEach (done) ->
    host = new enttec.Enttec path: null

    host.add new enttec.RGBLight address: 8
    host.add new enttec.RGBLight address: 16
    host.add new enttec.RGBLight address: 24
    host.devices[0].set 255, 0, 0
    host.devices[1].set 0, 254, 0
    host.devices[2].set 0, 0, 253

    host.serial = write: (data2) ->
      data = data2
      done()

    host.commit()

  it "Sets the first light's red intensity in the buffer", ->
    assert.equal data[dmxHeaders.length + 8 + 0], 255

  it "Sets the second light's green intensity in the buffer",->
    assert.equal data[dmxHeaders.length + 16 + 1], 254

  it "Sets the third light's blue intensity in the buffer",->
    assert.equal data[dmxHeaders.length + 24 + 2], 253


describe "RGB lights in Enttec host", ->
  host = null

  beforeEach ->
    host = new enttec.Enttec path: null
    host.serial = write: ->

  it "can have two lights", ->
    host.add new enttec.RGBLight address: 8
    host.add new enttec.RGBLight address: 16

  it "can have two lights added in tightly packed addresses", ->
    host.add new enttec.RGBLight address: 8
    host.add new enttec.RGBLight address: 13

  it "can have two lights added in tightly packed addresses (reverse order)", ->
    host.add new enttec.RGBLight address: 13
    host.add new enttec.RGBLight address: 8

  it "should throw if a new light added after an existing one overlaps with it", ->
    host.add new enttec.RGBLight address: 8
    assert.throws ->
      host.add new enttec.RGBLight address: 10

  it "should throw if a new light added before an existing one overlaps with it", ->
    host.add new enttec.RGBLight address: 8
    assert.throws ->
      host.add new enttec.RGBLight address: 5

  it "should throw if a new light is placed in the same address as an existing one",  ->
    host.add new enttec.RGBLight address: 8
    assert.throws ->
      host.add new enttec.RGBLight address: 8
