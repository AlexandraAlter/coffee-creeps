'use strict'

log = require 'log'
Zone = require 'zone'
Node = require 'node'
Cortex = require 'cortex'

logger = log.getLogger 'sys.expansion'
l = log.fmt


class ExpansionNode extends Node

class ExpansionCortex extends Cortex
  @defineMemory ['sys', 'expansion']


module.exports = {
  toString: -> '[module sys.expansion]'
  ExpansionNode
  ExpansionCortex
}
