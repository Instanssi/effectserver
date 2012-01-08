
fs = require "fs"
dgram = require "dgram"
util = require "util"
{EventEmitter} = require('events')

CSON = require "cson"

{EffectManager} = require "./lib/effectmanager"
{packetParse} = require "./lib/packetparser"


{webserver, websocket} = require "./web/webserver"
udbserver = dgram.createSocket("udp4")


try
  config = CSON.parseFileSync __dirname + "/config.cson"
catch e
  config = JSON.parse fs.readFileSync __dirname + "/config.json"


manager = new EffectManager config.hosts, config.mapping
manager.build()


webserver.get "/config.json", (req, res) ->
  res.json manager.toJSON()


udbserver.on "message", (packet, rinfo) ->

  try
    cmds = packetParse packet
  catch e
    # TODO: catch only parse errors
    websocket.emit "parseError",
      error: "Failed to parse whole packet: #{ e.message }"
      address: rinfo.address

    # Failed to parse the packet. We cannot continue from here at all.
    return

  # Packet starts as anonymous always
  tag = "anonymous"

  results = []

  for cmd in cmds

    # First fragment might tag this packet
    if cmd.tag
      tag = cmd.tag
      continue # to next fragment

    error = manager.route cmd
    results.push
      address: rinfo.address
      tag: tag
      cmd: cmd
      error: error?.message

  manager.commitAll()
  websocket.emit "cmds", results



websocket.on "cmds", (cmds) ->
  for cmd in cmds
    console.log "WEB", cmd


udbserver.on "listening", ->
  console.log "Now listening on UDP port #{ config.servers.udpPort }"
udbserver.bind config.servers.udpPort

webserver.listen config.servers.httpPort, ->
  console.log "Now listening on HTTP port #{ config.servers.httpPort }"

