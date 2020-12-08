'use strict'

log = require 'log'
Zone = require 'zone'
Node = require 'node'
Cortex = require 'cortex'

logger = log.getLogger 'sys.war'
l = log.fmt


class WarNode extends Node

class WarCortex extends Cortex
  @defineMemory ['sys', 'war']


module.exports = {
  toString: -> '[module sys.war]'
  WarNode
  WarCortex
}
