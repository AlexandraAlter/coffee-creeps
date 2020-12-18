export enum Level {
  Trace = 1,
  Info,
  Warn,
  Error,
  Fatal,
}

let globalLevel: Level = Memory.logLevel
if (!globalLevel || typeof globalLevel != 'number' ||
  globalLevel < Level.Trace || globalLevel > Level.Fatal) {
  setGlobalLevel(Level.Info)
}

export function setGlobalLevel(level?: Level): void {
  if (level) {
    globalLevel = level
    Memory.logLevel = level
  } else {
    throw Error('bad level')
  }
}

export class Logger {
  static toString(): string {
    return `[class ${this.name}]`
  }

  constructor(
    readonly name: string,
    public _level?: Level,
    public parent?: Logger
  ) {}

  toString(): string {
    return `[${this.constructor.name} level=${Level[this.curLevel]}]`
  }

  get level(): Level | undefined {
    return this._level
  }
  set level(val: Level | undefined) {
    if (this._level !== val) {
      this._level = val
      let msg = val
        ? `level ${val}`
        : this.parent
        ? 'parents level'
        : 'global level'
      this.info(`logging at ${msg}`)
    }
  }

  get curLevel(): Level {
    if (this.level) {
      return this.level
    } else if (this.parent) {
      return this.parent.curLevel
    } else {
      return globalLevel
    }
  }

  log(prefix: string, str: string | (() => string), opts?: object): void {
    if (typeof str === 'function') {
      str = str()
    }
    console.log(prefix, '[' + this.name + ']', str)
  }

  debug(str: string, opts?: object) {
    this.log('debug:', str, opts)
  }

  // report(report: Report) {
  //   this.log('report:', report.toString(), null);
  // }

  trace(str: string, opts?: object) {
    if (this.curLevel <= Level.Trace) {
      this.log('trace:', str, opts)
    }
  }

  info(str: string, opts?: object) {
    if (this.curLevel <= Level.Info) {
      this.log('info:', str, opts)
    }
  }

  warn(str: string, opts?: object) {
    if (this.curLevel <= Level.Warn) {
      this.log('warn:', str, opts)
    }
  }

  error(str: string, opts?: object) {
    if (this.curLevel <= Level.Error) {
      this.log('error:', str, opts)
    }
  }

  fatal(str: string, opts?: object) {
    if (this.curLevel <= Level.Fatal) {
      this.log('fatal:', str, opts)
    }
  }
}

var loggers: Set<Logger> = new Set()

export function getLogger(
  name: string,
  level?: Level,
  parent?: Logger
): Logger {
  for (let logger of loggers) {
    if (logger.name === name) {
      if (logger.level !== level) {
        throw Error('mismatched levels')
      }

      if (logger.parent !== parent) {
        throw Error('mismatched parents')
      }

      return logger
    }
  }

  let l = new Logger(name, level, parent)
  loggers.add(l)
  return l
}

export function fmt(strings: string[], ...exps: any[]): () => string {
  return function () {
    return strings.reduce(function (acc, text, i) {
      var val = exps[i - 1]
      if (val != null) {
        val = val.toString()
      }
      return acc + val + text
    })
  }
}
