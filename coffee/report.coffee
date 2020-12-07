'use strict'

log = require 'log'

logger = log.getLogger 'report'
l = log.fmt


class Report
  constructor: (@name) ->
    @curIndent = 0
    @str = ''

  add: (str) -> @str += str
  addIndent: -> @str += '  '.repeat(@curIndent)
  addLine: (str) -> @addIndent(); @str += str + '\n'

  indent: -> @curIndent += 1
  dedent: -> @curIndent -= 1 if @curIndent > 0
  withIndent: (func) ->
    @indent()
    try
      func()
    finally
      @dedent()

  toString: -> "#{@name}\n#{@str}"


b_to_mb = (b) ->
  mb = b // 1000000
  mbEnd = b % 1000000
  kb = mbEnd // 1000
  bEnd = mbEnd % 1000
  String(mb) + 'mb ' + String(kb) + 'kb ' + String(bEnd) + 'b'


b_to_mbi = (b) ->
  mbi = b // 1048576
  mbiEnd = b % 1048576
  kbi = mbiEnd // 1024
  bEnd = mbiEnd % 1024
  String(mbi) + 'mbi ' + String(kbi) + 'kbi ' + String(bEnd) + 'b'


i_to_bool = (i) -> i > 0


cores = ->
  report = new Report 'cores'

  sys = Sys
  report.addLine sys

  report.withIndent =>
    report.addLine 'brain: ' + sys.brain
    for cortex in sys.brain.cortexes
      report.addLine '- ' + 'cortex'

  report.withIndent =>
    report.addLine 'creeps:'
    for cortex in sys.creeps
      report.addLine '- ' + 'creep'

  report.withIndent =>
    report.addLine 'rooms:'
    for cortex in sys.rooms
      report.addLine '- ' + 'room'

  report.withIndent =>
    report.addLine 'tasks:'
    for cortex in sys.tasks
      report.addLine '- ' + 'task'

  logger.report report


memory = ->
  report = new Report 'memory'
  mem = Game.cpu.getHeapStatistics()
  for name, val of mem
    if name is 'does_zap_garbage'
      report.addLine "#{name}: #{i_to_bool val}"
    else
      report.addLine "#{name}: #{b_to_mbi val}"
  logger.report report


module.exports = {
  Report
  cores
  memory
}
