
assert = require "assert"

vows = require "vows"
_  = require 'underscore'

enttec = require "../enttec"

dmxHeaders = new Buffer [0x7e, 6, 0, 2]

batches = vows.describe("Enttec").addBatch

  "RGB Light":
    topic: ->
      light = new enttec.RGBLight address: 8
      light.set 0, 255, 0
      light

    "Has length of 5": (light) ->
      assert.isTrue light.getLength() is 5

    "Is green": (light) ->
      assert.deepEqual light.toBuffer(), new Buffer [0, 0, 255, 0, 0]

  "Enttec host buffer":
    topic: ->

      host = new enttec.Enttec path: "/dev/null"
      host.serial = write: (data) =>
        @callback null, data
      host.commit()
      undefined

    "Headers match the spec": (err, data) ->
      assert.deepEqual data.slice(0, dmxHeaders.length), dmxHeaders

    "Ending must be 0xe7": (err, data) ->
      assert.equal data[data.length-1], 0xe7


  "RGB Lights in host buffer":
    topic: ->
      host = new enttec.Enttec path: "/dev/null"

      host.add new enttec.RGBLight address: 8
      host.add new enttec.RGBLight address: 16
      host.devices[0].set 255, 0, 0
      host.devices[1].set 0, 255, 0

      host.serial = write: (data) =>
        @callback null, data

      host.commit()
      undefined

    "First light is red": (err, data) ->
      assert.equal data[dmxHeaders.length + 8 + 1], 255

    "Second light is green": (err, data) ->
      assert.equal data[dmxHeaders.length + 16 + 2], 255


  "Enttec host":
    topic: ->
      host = new enttec.Enttec path: "/dev/null"
      host.serial = write: ->
      host

    "Two lights can be added": (host) ->
      host.devices = []
      assert.doesNotThrow ->
        host.add new enttec.RGBLight address: 8
        host.add new enttec.RGBLight address: 16

    "Two lights can be added close to each others": (host) ->
      host.devices = []
      assert.doesNotThrow ->
        host.add new enttec.RGBLight address: 8
        host.add new enttec.RGBLight address: 13


    "Two lights can be added close to each others2": (host) ->
      host.devices = []
      assert.doesNotThrow ->
        host.add new enttec.RGBLight address: 13
        host.add new enttec.RGBLight address: 8

    "Second light cannot start before previous ends": (host) ->
      host.devices = []
      assert.doesNotThrow ->
      host.add new enttec.RGBLight address: 8

      assert.throws ->
        host.add new enttec.RGBLight address: 10

    "Second added light ending cannot clash with previous": (host) ->
      host.devices = []
      assert.doesNotThrow ->
      host.add new enttec.RGBLight address: 8

      assert.throws ->
        host.add new enttec.RGBLight address: 5

    "Second light cannot be on top of previous": (host) ->
      host.devices = []
      assert.doesNotThrow ->
      host.add new enttec.RGBLight address: 8

      assert.throws ->
        host.add new enttec.RGBLight address: 8


batches.export module




