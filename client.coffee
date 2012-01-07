

dgram = require('dgram')
client = dgram.createSocket("udp4")

message = new Buffer [
  1 # spec version

  , 1 # Type. 1 means light
  , 0 # light id
  , 0 # Light type. 0 means rgb
  , 0 # R
  , 0   # G
  , 255   # B

  # , 1 # Type. 1 means light
  # , 1 # light id
  # , 0 # Light type. 0 means rgb
  # , 255   # R
  # , 0 # G
  # , 0   # B
]


client.send message, 0, message.length, 9909, "127.0.0.1", (err, bytes) ->
  console.log "sent"
  console.log err, bytes

  client.close()

