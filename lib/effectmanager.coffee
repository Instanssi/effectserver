util = require "util"

enttec = require "./enttec"





class EffectGroup

  constructor: (@type) ->
    @devices = {}

  mapDevice: (virtualId, device) ->

    if @type isnt device.type
      throw new Error "Cannot add type #{ device.type } to #{ @type } type group"

    @devices[virtualId] = device

  toJSON: ->
    ob = {}
    for id, device of @devices
      ob[id] = device.toJSON()
    ob

  getDevice: (virtualId) ->
    @devices[virtualId]

  setAll: (args...) ->
    for device in @devices
      devices.set.apply device, args
    undefined



class EffectManager

  constructor: (@hosts, @mapping) ->
    @groups = {}

  deviceClasses:
    light:
      rgb: enttec.RGBLight

  hostClasses:
    enttec: enttec.Enttec

  commitAll: ->
    for k, host of @hosts
      host.commit()

  toJSON: ->
    ob = {}
    for k, group of @groups
      ob[k] = group.toJSON()
    ob

  build: ->

    for hostName, hostOpts of @hosts

      if Host = @hostClasses[hostOpts.type]
        @hosts[hostName] = new Host hostOpts
        console.log "Created host:", hostName, hostOpts.type
      else
        throw new Error "Unknown host type #{ hostOpts.type }"

    for deviceClass, deviceMap of @mapping

      group = @groups[deviceClass] = new EffectGroup deviceClass
      console.log "Created group with #{ deviceClass }"

      for virtualId, deviceOpts of deviceMap

        # console.log "#{ hostName }: dip pos for #{ deviceOpts.address }:", addressToDip deviceOpts.address

        if Device = @deviceClasses[deviceClass]?[deviceOpts.type]
          device = new Device deviceOpts
        else
          throw new Error "Unkdown device type #{ deviceOpts.type }"

        if host = @hosts[deviceOpts.host]
          host.add device
        else
          throw new Error "Undefined host #{ deviceOpts.host }"

        group.mapDevice virtualId, device

    console.log "GROUPS", @groups

  # Routes command to correct device
  route: (cmd) ->

    deviceGroup = @groups[cmd.deviceType]

    if not deviceGroup
      return new Error "Unknown device group #{ cmd.deviceType }"

    device = deviceGroup.devices[cmd.id]
    if not device
      return new Error "Unkown virtual id #{ cmd.id }"

    device.execute cmd


exports.EffectGroup = EffectGroup
exports.EffectManager = EffectManager
