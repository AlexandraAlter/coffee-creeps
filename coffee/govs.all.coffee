'use strict'

govs = require 'govs'
upgov = require 'govs.upkeep'
buildgov = require 'govs.build'
defgov = require 'govs.combat'

module.exports = new Proxy(govs, upgov, buildgov, defgov)
