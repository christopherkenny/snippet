#set page(height: auto, width: {{WIDTH}}in)
#set raw(theme: {{THEME}})
#set text(fill: rgb({{FOREGROUND}}))

#let line-numbers = {{LINE_NUMBERS}}
#show raw.line: it => {
  if line-numbers {
    box(stack(dir: ltr, box(width: 2em)[#it.number], it.body))
  } else {
    it
  }
}

#let titled-raw-block(body, title: none, style: "mac", background: luma(230)) = {
  // Define button layouts using stack
  let mac-buttons = stack(
    dir: ltr,
    spacing: 0.15em,
    circle(radius: 0.3em, fill: rgb("FF5F56")),
    circle(radius: 0.3em, fill: rgb("FFBD2E")),
    circle(radius: 0.3em, fill: rgb("27C93F"))
  )

let win-buttons = stack(
  dir: ltr,
  spacing: 0.25em,

  // Minimize
  block(
    height: 1em,
    width: 1em,
    fill: luma(240),
    radius: 2pt,
    inset: 0.15em,
  )[#align(center + horizon)[#sym.dash.em]],

  // Maximize / Restore
  block(
    height: 1em,
    width: 1em,
    fill: luma(240),
    radius: 2pt,
  )[

    #set align(center + horizon)
    #rect(
  height: 0.5em,
  width: 0.5em,
  radius: 0.1em,
  stroke: 0.6pt + black
)

#place(
  center+ horizon,
  dx: 1.25pt,
  dy: -1.25pt
)[
  #rect(
  height: 0.5em,
  width: 0.5em,
  radius: (top-right: 0.1em),
  stroke: (top: 0.6pt, right: 0.6pt, rest: none)
)
]],

  // Close
  block(
    height: 1em,
    width: 1em,
    fill: luma(240),
    radius: 2pt,

  )[#align(center + bottom)[#text("×", 18pt)]]
)

  // Determine layout content
  let (lft, cntr, rght) = if style == "mac" {
    (mac-buttons, if title != none { strong(title) } else { text("") }, none)
  } else if style == "windows" {
    (none, if title != none { strong(title) } else { text("") }, win-buttons)
  } else {
    (none, if title != none { strong(title) } else { text("") }, none)
  }

  block(
    inset: 0em,
    fill: background,
    radius: 8pt,
    outset: 0.75em,
    width: 100%,
    spacing: 2em,
    [
      // Title bar with shared background
      #box(
        width: 100%,
        radius: (top-left: 8pt, top-right: 8pt),
        [
          #grid(
            columns: (1fr, 1fr, 1fr),
            align: (left, center, right),
              lft,
              cntr,
              rght
          )
        ]
      )

      // Code block using same background
      #block(
        fill: background,
        inset: 0em,
        above: 1.2em,
        outset: 0.75em,
        radius: (bottom-left: 8pt, bottom-right: 8pt),
        width: 100%,
        body
      )
    ]
  )
}

#titled-raw-block(
  title: {{TITLE}},
  style: {{STYLE}},
  background: rgb({{BACKGROUND}}),
  raw(lang: {{LANG}}, block: true, "{{CODE}}")
)
