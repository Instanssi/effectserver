
enttec = require "./enttec"


class EffectGroup

  constructor: (@type) ->
    @devices = {}

  mapDevice: (virtualId, device) ->

    if @type isnt device.type
      throw new Error "Cannot add type #{ device.type } to #{ @type } type group"

    @devices[virtualId] = device

  getDevice: (virtualId) ->
    @devices[virtualId]

  setAll: (args...) ->
    for device in @devices
      devices.set.apply device, args
    null



class EffectManager

  constructor: (@setup) ->
    @groups = {}
    @hosts = {}

  deviceClasses:
    lights:
      rgb: enttec.RGBLight

  hostClasses:
    enttec: enttec.Enttec

  commitAll: ->
    for k, host of @hosts
      host.commit()

  build: ->

    for hostName, hostOpts of @setup.hosts
      if Host = @hostClasses[hostOpts.type]
        @hosts[hostName] = new Host hostOpts
        console.log "Host:", hostName, hostOpts.type
      else
        throw new Error "Unknown host type #{ hostOpts.type }"

    for deviceClass, deviceMap of @setup.mapping

      group = @groups[deviceClass] = new EffectGroup deviceClass

      for virtualId, deviceOpts of deviceMap
        console.log virtualId, deviceOpts

        if Device = @deviceClasses[deviceClass]?[deviceOpts.type]
          device = new Device deviceOpts
        else
          throw new Error "Unkdown device type #{ deviceOpts.type }"

        if host = @hosts[deviceOpts.host]
          host.add device
        else
          throw new Error "Undefined host #{ deviceOpts.host }"

        group.mapDevice virtualId, device


exports.EffectGroup = EffectGroup
exports.EffectManager = EffectManager
