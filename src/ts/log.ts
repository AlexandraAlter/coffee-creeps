'use strict'

function fmt(strings: string[], ...exps: any[]): () => string {
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

export = {
  fmt,
}
