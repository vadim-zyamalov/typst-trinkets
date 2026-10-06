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
// Значение параметра `delim` должно быть преваряться #, дабы typst не интерпретировал его как часть формулы,
// ибо это за него будем делать мы.
#let autolr(eq, delim: ("(", ")")) = context {
  let ld = symbol(delim.at(0))
  let rd = symbol(delim.at(1))
  let wh = none
  {
    show math.underbrace: it => it.body
    show math.overbrace: it => it.body
    wh = measure(eq)
  }
  math.lr(size: wh.height, $ld eq rd$)
}

// Данная функция оборачивает печатную (блочную) функцию в нумеруемый блок.
// Это нужно чтобы:
// а) чтобы ссылки на формулы работали (в typst ссылки без номера не работают),
// б) чтобы можно было нумеровать конкретные формулы.
#let eqnum(eq, numbering: "(1)") = math.equation(
  block: true,
  numbering: numbering,
  eq,
)

// Переопределение заголовков в приложениях.
#let appendix(body, supplement: [Приложение], numbering: "A") = {
  set heading(numbering: numbering, supplement: supplement)
  body
}

#let neat-document(
  indent: 2em,
  leading: 1.5em,
  fonts: (:),
  margin: (:),
  lang: "ru",
  doc,
) = {
  // Обновляем значения по умолчанию собственными значениями.
  let inner-settings = neat-settings
  inner-settings.margin += margin
  inner-settings.fonts += fonts

  // Настройки страницы.
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

  // Настройки параграфов.
  set par(
    justify: true,
    leading: leading,
    first-line-indent: (amount: indent, all: true),
  )

  // Убираем переносы в заголовке документа.
  show title: set par(justify: false)

  // Отступы в списках
  set enum(indent: indent)
  set list(indent: indent)

  // Делаем блочные матрицы более сжатыми по вертикали и разрешаем разрыв блока между страницами.
  show math.equation.where(block: true): set block(breakable: true)
  show math.equation.where(block: true): set par(leading: 0.75em)

  // Добавляем горизонтальное расстояние между колонками в матрицах.
  set math.mat(column-gap: 1em)

  // Делаем блоки сырого текста более сжатыми по вертикали.
  show raw.where(block: true): set par(leading: 0.75em)

  // Задаем шрифты.
  set text(lang: lang, font: inner-settings.fonts.main, size: inner-settings.fonts.size)
  show raw: set text(font: inner-settings.fonts.mono)
  show math.equation: set text(font: inner-settings.fonts.math)

  // Добавим вертикальный пробел после заголовков.
  show heading: it => block(it + v(0.5em))

  // Ссылки на уравнения в виде (1).
  // Данная функция предназначена для стандартных ссылок на формулы:
  // заменяет "Уравнение X" на "(X)".
  // https://typst.app/docs/reference/model/ref/
  show ref: it => {
    let el = it.element
    // Skip all other references.
    if el == none or el.func() != math.equation { return it }
    // Override equation references.
    link(el.location(), counter(math.equation).display(at: el.location()))
  }

  // То же самое, но для формул, нумерованных пакетом equate.
  // Это нужно делать специально, так как equate заново пересобирает все формулы,
  // в том числе и ссылки на них.
  // https://github.com/EpicEricEE/typst-equate/issues/11#issuecomment-2633709934
  set math.equation(supplement: none, numbering: (..nums) => numbering("(1)", ..nums))

  // Применяем к документу функции из импортированных пакетов.
  show: par-indent
  show: equate.with(breakable: true, number-mode: "label")
  show: breathe

  // Размещаем заголовок документа.
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
  )[#title()]

  // Тело документа.
  doc
}
