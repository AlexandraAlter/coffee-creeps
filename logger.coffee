'use strict'

_ = require 'lodash'

levels =
  TRACE: 1
  INFO: 2
  WARN: 3
  ERROR: 4
  FATAL: 5

if not Memory.logLevel?
  Memory.logLevel = levels.INFO


getOpts = (strs) ->
  opts = _.last(strs)
  if typeof opts is 'object'
    [_.initial(strs), opts]
  else
    [strs, {}]


getIndent = (opts) ->
  if opts.indent?
    '|-'.repeat(opts.indent)
  else ''


getLevel = -> Memory.logLevel


doLog = (prefix, strs...) ->
  [strs, opts] = getOpts strs
  console.log(getIndent(opts) + prefix, strs...)


log = (strs...) ->
  doLog('log:', strs...)


trace = (strs...) ->
  if getLevel() <= levels.TRACE
    doLog('trace:', strs...)


info = (strs...) ->
  if getLevel() <= levels.INFO
    doLog('info:', strs...)


warn = (strs...) ->
  if getLevel() <= levels.WARN
    doLog('warn:', strs...)


error = (strs...) ->
  if getLevel() <= levels.ERROR
    doLog('error:', strs...)


fatal = (strs...) ->
  if getLevel() <= levels.FATAL
    doLog('fatal:', strs...)


info 'logging at level', _.findKey levels, (v) -> v is getLevel()


module.exports = { levels, log, trace, info, warn, error, fatal }

