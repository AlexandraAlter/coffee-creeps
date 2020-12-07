'use strict'

Worker = require 'worker.core'
robots = require 'worker.robots'
structs = require 'worker.structs'
SpawnWorker = require 'worker.spawn'


do linkAllProtos = ->
  for name, w of robots
    w.linkProto()
  for name, w of structs
    w.linkProto()
  SpawnWorker.linkProto()


module.exports = {
  Worker
  robots...
  structs...
  linkAllProtos
}
