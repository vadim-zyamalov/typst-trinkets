#import "@preview/parize:0.2.1": par-indent
#import "@preview/breather:0.1.0": breathe
#import "@preview/equate:0.3.3": equate

#let neat-settings = (
  margin: (
    top: 1.5cm,
    bottom: 1.5cm,
    inside: 3cm,
    outside: 1.5cm,
  ),
  fonts: (
    main: "Noto Serif",
    sans: "Noto Sans",
    mono: "Noto Sans Mono",
    math: "Noto Sans Math",
    size: 12pt,
  ),
)

// Данный код позволяет игнорировать underbrace при определении высоты скобок
// https://forum.typst.app/t/how-to-recreate-latex-smash-and-vphantom-in-typst-math/8413/3
// Значение параметра `delim` должно быть заключено в #{}, так как, по всей видимости,
// без этого Typst воспринимает значение как формулу и не понимает, чего мы хотим от него.
#let autolr(eq, delim: ("(", ")")) = context {
  let ld = symbol(delim.at(0))
  let rd = symbol(delim.at(1))
  let wh = none
  {
    show math.underbrace: it => it.body
    wh = measure(eq)
  }
  math.lr(size: wh.height, $ld eq rd$)
}

#let eqnum(eq) = math.equation(block: true, numbering: "(1)", eq)

#let appendix(body, supplement: [Приложение], numbering: "A") = {
  set heading(numbering: numbering, supplement: supplement)
  body
}

#let neat-document(
  indent: 2em,
  leading: 1.5em,
  fonts: (:),
  margin: (:),
  doc,
) = {
  let inner-settings = neat-settings
  inner-settings.margin += margin
  inner-settings.fonts += fonts

  // Настройки страницы
  set page(
    paper: "a4",
    header: context {
      let page_num = counter(page).at(here()).first()
      if page_num != 1 {
        if calc.odd(page_num) {
          align(right)[#document.title]
        } else {
          align(left)[#document.title]
        }
      }
    },
    footer: context align(center)[#counter(page).display("1", both: false)],
    columns: 1,
    margin: inner-settings.margin,
  )

  // Настройки параграфов
  set par(
    justify: true,
    leading: leading,
    first-line-indent: (amount: indent, all: true),
  )

  set enum(indent: indent)
  set list(indent: indent)
  show math.equation.where(block: true): set block(breakable: true)
  show math.equation.where(block: true): set par(leading: 0.75em)
  set math.mat(column-gap: 1em)
  show raw.where(block: true): set par(leading: 0.75em)

  // Задаем шрифты
  set text(lang: "ru", font: inner-settings.fonts.main, size: inner-settings.fonts.size)
  show raw: set text(font: inner-settings.fonts.mono)
  show math.equation: set text(font: inner-settings.fonts.math)

  // Добавим вертикальный пробел после заголовка
  show heading: it => block(it + v(0.5em))

  // Ссылки на уравнения в виде (1)
  // https://typst.app/docs/reference/model/ref/
  show ref: it => {
    let eq = math.equation
    let el = it.element
    // Skip all other references.
    if el == none or el.func() != eq { return it }
    // Override equation references.
    link(el.location(), counter(eq).display(at: el.location()))
  }

  // https://github.com/EpicEricEE/typst-equate/issues/11#issuecomment-2633709934
  set math.equation(supplement: none, numbering: (..nums) => numbering("(1)", ..nums))

  // Размещаем заголовок документа
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
  )[#title()]

  show: par-indent
  show: equate.with(breakable: true, number-mode: "label")
  show: breathe

  doc
}
