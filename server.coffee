CSON = require "cson"
dgram = require "dgram"
ws = require "ws"
fs = require "fs"
util = require "util"
EventEmitter = require "events"

process.on 'uncaughtException', (err) ->
  console.log 'Caught exception', err

{EffectManager} = require "./lib/effectmanager"
{packetParse} = require "./lib/packetparser"

{webserver, websocket} = require "./web/webserver"
udpserver = dgram.createSocket("udp4")


onConfigRead = (error, config) ->
  if error
    console.error 'failed to read configuration file:', error
    throw error
  webserver.config = config

  manager = new EffectManager config.hosts, config.mapping
  manager.build()

  webserver.get "/config.json", (req, res) ->
    res.json manager.toJSON()

  if process.env.TAG
    firewall =
      allowOnly:
        tag: process.env.TAG

    setTimeout ->
      console.log "FIREWALL", firewall
    , 1000

  processPacket = (packet, rinfo) ->
    try
      cmds = packetParse packet
    catch e
      # TODO: catch only parse errors
      websocket.sockets.volatile.emit "parseError",
        error: e.message
        address: rinfo.address

      # Failed to parse the packet. We cannot continue from here at all.
      return

    results =
      # Packet starts as anonymous always
      tag: "anonymous"
      address: rinfo.address
      cmds: []

    for cmd in cmds

      # First fragment might tag this packet
      if cmd.tag
        results.tag = cmd.tag.substring(0, 15)
        continue # to next fragment

      if firewall?
        if results.tag isnt firewall.allowOnly.tag
          console.log "Bad tag '#{ results.tag }' we need '#{ firewall.allowOnly.tag }'"
          continue

      if error = manager.route cmd
        cmd.error = error

      results.cmds.push cmd


    manager.commitAll()

    # No debug when firewall is on
    if not firewall?
      websocket.sockets.volatile.emit "cmds", results

  wsserver = new ws.Server { port: config.servers.webSocketPort, host: config.servers.webSocketHost }

  wsserver.on "listening", ->
    console.log "Now listening WebSocket on #{ config.servers.webSocketHost }:#{ config.servers.webSocketPort }"

  wsserver.on 'connection', (socket, req) ->
    socket.on 'message', (packet) ->
      processPacket packet, { address: req.connection.remoteAddress }

  udpserver.on "message", (packet, rinfo) ->
    processPacket packet, rinfo

  udpserver.on "listening", ->
    console.log "Now listening on UDP port #{ config.servers.udpPort }"
  udpserver.bind config.servers.udpPort

  webserver.listen config.servers.httpPort, ->
    console.log "Now listening on HTTP port #{ config.servers.httpPort }"

try
  CSON.parseFile __dirname + '/config.cson', { format: 'cson' }, onConfigRead
catch e
  console.log 'Unable to read config.cson!', e
  process.exit 1


