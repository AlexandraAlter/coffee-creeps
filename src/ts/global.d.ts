import type _ from 'lodash4'
// import type { SysCls } from './sys'
// import type { m, cl, s, c, r } from './cmd'

declare global {
  namespace NodeJS {
    export interface Global {
      // lodash 4
      _: typeof _

      // global state
      // Sys: SysCls

      // command layer
      // m: typeof m
      // cl: typeof cl
      // s: typeof s
      // c: typeof c
      // r: typeof r
    }
  }

  // export var Sys: SysCls
}
