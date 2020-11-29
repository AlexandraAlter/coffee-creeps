'use strict'

Edict = require 'edicts'
freq = require 'freq'
logger = require 'logger'
l = logger.fmt


StructureSpawn.cleanMemory = ->
  logger.info 'cleaning spawns'
  for sName of Memory.spawns
    if not Game.spawns[sName]?
      delete Memory.spawn[sName]


StructureSpawn::withBackoff = (func) ->
  if @backedOff
    return
  if @memory.backoff? and @memory.backoff > 0
    @memory.backoff--
    @backedOff = true
    return
  try
    return func.call @
  catch err
    @memory.backoff = 10
    logger.info l"backoff for #{@}"
    throw err


StructureSpawn::initFirstTime = ->
  logger.info l"initFirstTime for #{@}"
  if @memory.edict
    @memory.edict = Edict.newFromMem null, @memory.edict
  @memory.backoff = 0 if not @memory.backoff?


StructureSpawn::init = ->
  @withBackoff =>
    freq.onReload =>
      @initFirstTime()
    if @memory.edict
      @memory.edict = Edict.newFromMem null, @memory.edict


StructureSpawn::makeName = (role) ->
  loop
    name = role.name + '_' + Math.random().toString(36).substr(2, 5)
    if not Game.creeps[name]?
      break
  name


StructureSpawn::findEdict = ->
  for gName, gov of @room.memory.governors
    for eName, edict of gov.edicts
      if (edict instanceof Edict.SpawnerEdict) and edict.isReady()
        return edict


StructureSpawn::fail = ->
  @edict.fail @
  @memory.edictRef = null
  @memory.backoff = 20


StructureSpawn::complete = ->
  @edict.complete @
  @memory.edictRef = null


StructureSpawn::tick = ->
  @withBackoff =>
    logger.trace l"tick for #{@}"

    if not @isActive()
      return

    # TODO optimise for performance
    if @memory.edictRef
      @edict = Edict.newFromRef @memory.edictRef

    if (not @spawning) and (not @edict)
      edict = @findEdict()
      if edict
        @memory.edictRef = edict.toRef()
        @edict = edict
        @edict.start @
        logger.info l"#{@} starting #{@memory.edictRef}"

    if (not @spawning) and @edict and (@edict instanceof Edict.CreateCreeps)
      try
        role = @edict.role
        name = @makeName role
        body = role.selectParts 100
        cost = role.costOfParts body
        mem = {role: new role}
        res = @spawnCreep body, name, memory: mem
      catch err
        @fail()
        throw err
      if res is OK
        logger.info l"#{@} spawning #{name} with #{body} for #{cost}"
      else
        logger.error l"#{@} returned #{res}"
        @fail()

    if @spawning and (@edict instanceof Edict.CreateCreeps)
      if @spawning.remainingTime is 1
        @complete()


StructureSpawn::toString = ->
  "[StructureSpawn n=#{@name}]"
