'use strict'


#Harvester = require 'roles.harvester'
#Hauler = require 'roles.hauler'


class Role
  @variants = {}

  @id: null
  @parts: null

  @newFromMem: (creep, opts) ->
    new Role creep, opts

  constructor: (@creep, opts) ->


guessFromName = (name) ->
  if name.includes 'harvester'
    Harvester
  else if name.includes 'hauler'
    Hauler
  else null


getFromMem = (mem) ->
  if mem.roleid?
    switch mem.roleid
      when Harvester.id then Harvester
      when Hauler.id then Hauler
      else null
  else null


get = (creep) ->
  role = getFromMem creep.mem
  if not role?
    role = guessFromName creep.name
    creep.mem.roleid = role.id
  return role.fromCreep creep


set = (creep, role) ->
  creep.mem.roleid = role.id


module.exports = Role
