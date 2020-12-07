'use strict'

Worker = require 'worker.core'


class TowerWorker extends Worker
  @backingCls = StructureTower
  @defineMemory ['towers', null]


class ControllerWorker extends Worker
  @backingCls = StructureController
  @defineMemory ['controllers', null]


class ObserverWorker extends Worker
  @backingCls = StructureObserver
  @defineMemory ['observers', null]


class NukerWorker extends Worker
  @backingCls = StructureNuker
  @defineMemory ['nukers', null]


class LinkWorker extends Worker
  @backingCls = StructureLink
  @defineMemory ['links', null]


class LabWorker extends Worker
  @backingCls = StructureLab
  @defineMemory ['labs', null]


class TerminalWorker extends Worker
  @backingCls = StructureTerminal
  @defineMemory ['terminals', null]


class FactoryWorker extends Worker
  @backingCls = StructureFactory
  @defineMemory ['factories', null]


module.exports = {
  TowerWorker
  ControllerWorker
  ObserverWorker
  NukerWorker
  LinkWorker
  LabWorker
  TerminalWorker
  FactoryWorker
}
