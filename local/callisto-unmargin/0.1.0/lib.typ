#import "@preview/callisto:0.3.0"

// Скопировано из callisto, поскольку данная функция не экспортируется.
#let handle(data, mime: none, ctx: none, ..args) = {
  if ctx == none {
    panic("ctx not set")
  }
  if mime not in ctx.handlers {
    panic("no handle registered for MIME " + repr(mime))
  }
  let handler = ctx.handlers.at(mime)
  if handler == none {
    return none
  }
  ctx.mime = mime
  handler(data, ctx: ctx, ..args)
}

// Печать номера ячейки вынесена вовне.
#let un-handler-result(data, ctx: none, ..args) = handle(
  data,
  mime: "rich-output-generic",
  ctx: ctx,
  ..args,
)

// Функция для печати номера упрощена:
// она более не размещает подпись.
#let un-in-out-num(prefix, count) = context {
  let count-string = if count == none { return " " } else { str(count) }
  raw(prefix + "[" + count-string + "]:")
}

#let un-code-cell-input = (cell, ctx: none, block-args: none, ..args) => context {
  block(
    above: 2em,
    below: if ctx.output and cell.outputs.len() > 0 { 0pt } else { 2em },
    width: 100%,
    inset: 0.5em,
    ..block-args,
    grid(
      columns: (auto, 1fr),
      fill: (white, luma(240)),
      inset: 0.5em
    )[#un-in-out-num(" In ", cell.execution_count)][#handle(
      cell.source,
      mime: "source-code-generic",
      ctx: ctx,
      lang: ctx.lang,
    )],
  )
}

#let un-code-cell-output = (cell, ctx: none, ..args) => context {
  let outs = callisto.outputs(cell, ..ctx.cfg)
  if outs.len() == 0 { return }
  block(
    above: if ctx.input { 0pt } else { 2em },
    below: 2em,
    width: 100%,
    inset: 0.5em,
    grid(
      columns: (auto, 1fr),
      inset: 0.5em
    )[#un-in-out-num("Out ", cell.execution_count)][#outs.join()],
  )
}

#let unmargin-theme = (
  callisto.themes.notebook
    + (
      result: un-handler-result,
      code-cell-input: un-code-cell-input,
      code-cell-output: un-code-cell-output,
    )
)
