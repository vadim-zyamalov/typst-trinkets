#import "@preview/callisto:0.3.0"
#import "@preview/tschich:0.2.0": *
#import "@local/neat-document:0.1.0": neat-document

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

#let custom-handler-result(data, ctx: none, ..args) = handle(data, mime: "rich-output-generic", ctx: ctx, ..args)

// Add the In/Out annotation in the margin of code cell input/output
#let custom-in-out-num(prefix, count) = context {
  let count-string = if count == none { return " " } else { str(count) }
  raw(prefix + "[" + count-string + "]:")
}

#let custom-code-cell-input = (cell, ctx: none, block-args: none, ..args) => context {
  block(
    above: 2em,
    below: if ctx.output and cell.outputs.len() > 0 { 0pt } else { 2em },
    width: 100%, //100% - 1.2em - measure(mark).width,
    inset: 0.5em,
    ..block-args,
    grid(
      columns: (auto, 1fr),
      fill: (white, luma(240)),
      inset: 0.5em
    )[#custom-in-out-num(" In ", cell.execution_count)][#handle(
      cell.source,
      mime: "source-code-generic",
      ctx: ctx,
      lang: ctx.lang,
    )],
  )
}

#let custom-code-cell-output = (cell, ctx: none, ..args) => context {
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
    )[#custom-in-out-num("Out ", cell.execution_count)][#outs.join()],
  )
}

#set document(title: [<DUMMY>])
#show: neat-document.with(margin: tschich-var(210mm, 297mm, 1 / 12))

#let (render, Cell, In, Out) = callisto.config(
  nb: path("<DUMMY>.ipynb"),
  handlers: (path: (x, ..args) => path(x)),
  theme: callisto.themes.notebook
    + (
      result: custom-handler-result,
      code-cell-input: custom-code-cell-input,
      code-cell-output: custom-code-cell-output,
    ),
)

#render()
