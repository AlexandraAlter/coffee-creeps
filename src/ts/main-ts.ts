import { getLogger } from './log'
import { Freq } from './freq'

import { SysCls } from './sys'
import _ from 'lodash4'

import { m, cl, s, c, r } from './cmd'

let logger = getLogger('main')
void logger

export function setupGlobals(): void {
  global._ = _

  global.Sys = new SysCls()

  global.m = m
  global.cl = cl
  global.s = s
  global.c = c
  global.r = r
}

export function loop(): void {
  Freq.Reload.when(() => {
    Sys.reload()
    Freq.finishedReload()
  })
  Sys.clean()
  Sys.linkGame()
  Freq.Rarely.when(() => {
    Sys.refresh()
  })
  Sys.tick()
  Sys.clean()
}
