'use strict'

govs = require 'govs'
upgov = require 'govs.upkeep'
buildgov = null#require 'govs.build'
defgov = null#require 'govs.combat'

module.exports = Object.assign({}, govs, upgov, buildgov, defgov)
