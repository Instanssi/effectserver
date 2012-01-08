
fs = require "fs"
dgram = require "dgram"
{EventEmitter} = require('events')

CSON = require "cson"

{EffectManager} = require "./lib/effectmanager"
{app, io} = require "./web/webserver"


try
  config = CSON.parseFileSync __dirname + "/config.cson"
catch e
  config = JSON.parse fs.readFileSync __dirname + "/config.json"

console.log config

websocket = new EventEmitter

websocket.on "error", (user, msg) ->
  console.log "#{ user }: #{ msg }"


# manager = new EffectManager config.hosts, config.mapping
# manager.build()

udbserver = dgram.createSocket("udp4")

udbserver.on "message", (packet, rinfo) ->

  console.log "got msg"

  try
    cmds = parse packet
  catch e
    websocket.emit "error", user, "Failed to parse #{util.inspect packet} because: #{ e }"
    return

  tag = "anonymous"

  for cmd in cmds
    user = "#{ tag } (#{ rinfo.address }):"

    if cmd.tag
      tag = cmd
      continue

    {r, g, b} = cmd.cmd

    deviceGroup = manager.groups[cmd.deviceType]
    if not deviceGroup
      websocket.emit "error", user, "Unknown device group #{ cmd.deviceType }"
      continue

    device = deviceGroup.devices[cmd.id]
    if not device
      websocket.emit "error", user, "Unkown virtual id #{ cmd.id }"
      continue

    device.set r, g, b


  manager.commitAll()


udbserver.on "listening", ->
  console.log "Now listening on UDP port #{ config.servers.udpPort }"
udbserver.bind config.servers.udpPort

app.listen config.servers.httpPort, ->
  console.log "Now listening on HTTP port #{ config.servers.httpPort }"

