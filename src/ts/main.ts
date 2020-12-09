'use strict'

import log = require('./log')
import _ = require('lodash')
import lo = require('lodash4')

try {
  log.fmt(['a'])
  _.map([])
  lo.concat([])
} catch (e) {}

function tick(): void {}

module.exports.loop = tick
