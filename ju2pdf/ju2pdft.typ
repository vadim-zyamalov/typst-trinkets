#import "@preview/callisto:0.3.0"
#import "@local/callisto-unmargin:0.1.0": unmargin-theme
#import "@preview/tschich:0.2.0": *
#import "@local/neat-document:0.1.0": neat-document

#set document(title: [<DUMMY>])
#show: neat-document.with(margin: tschich-var(210mm, 297mm, 1 / 12))

#let (render, Cell, In, Out) = callisto.config(
  nb: path("<DUMMY>.ipynb"),
  handlers: (path: (x, ..args) => path(x)),
  theme: unmargin-theme,
)

#render()
