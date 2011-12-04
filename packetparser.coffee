






lightParser = do ->


  rgbLightParser = (packet) ->
    console.log "rgb packet", packet
    packet: packet.slice 3, packet.length
    data:
      lightType: "rgb"
      r: packet[0]
      g: packet[1]
      b: packet[2]

  lightParsers =
    0: rgbLightParser


  (packet) ->
    console.log "lightpacket", packet
    id = packet[0]
    type = packet[1]
    parser = lightParsers[type]

    if not parser
      throw new Error "Unknown light type #{ type }"

    {data, packet} = parser packet.slice 2, packet.length

    packet: packet
    data:
      deviceType: "light"
      id: id
      cmd: data



deviceParsers =
  1: lightParser



versionOneParser = (packet, cmds=[]) ->

  console.log "spec one", packet

  type = packet[0]

  parser = deviceParsers[type]
  if not parser
    throw new Error "Unkown device type #{ type }"

  # Drop device type and pass rest of the packet to the specific
  # device parser
  {data, packet} = parser packet.slice 1, packet.length

  cmds.push data

  if packet.length is 0
    # The whole packet is parsed. Return the result
    return cmds
  else
    # There is something to left to parse. Recurse
    versionOneParser packet, cmds



main = (packet) ->
  console.log "\n\nmain packet", packet

  if packet[0] isnt 1
    throw new Error "Unknown spec version"

  # Drop spec version
  versionOneParser packet.slice 1, packet.length





exports.parse = main
