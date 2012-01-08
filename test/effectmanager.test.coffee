
should = require "should"

{EffectManager, EffectGroup} = require "../lib/effectmanager"


describe "Effect Manager with few lights", ->

  manager = new EffectManager
    enttec1:
      path: "/dev/null"
      type: "enttec"
  ,
    light:
      0:
        name: "just my test light"
        host: "enttec1"
        type: "rgb"
        address: 2
      3:
        name: "another test light"
        host: "enttec1"
        type: "rgb"
        address: 8

  manager.build()

  it "should generate JSON output of the config", ->
    console.log manager.toJSON()

    should.deepEqual manager.toJSON(), {
      "light": {
        "0": {
          "address": 2,
          "type": "light",
          "name": "just my test light",
          "dipConfig": "01000000",
          "dmxChannels": 5
        },
        "3": {
          "address": 8,
          "type": "light",
          "name": "another test light",
          "dipConfig": "00010000",
          "dmxChannels": 5
        }
      }
    }
