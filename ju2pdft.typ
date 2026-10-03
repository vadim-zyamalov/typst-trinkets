#import "@preview/callisto:0.3.0"

#set par(justify: true)
#set text(font: "Noto Serif", lang: "ru")
#show math.equation: set text(
  font: "Noto Sans Math",
)
#set heading(numbering: none)

#let (render, Cell, In, Out) = callisto.config(
  nb: path("<DUMMY>.ipynb"),
  handlers: (path: (x, ..args) => path(x)),
)

#render()
