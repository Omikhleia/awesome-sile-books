-- Quick and dirty script to generate tables of mathvariant characters dynamically.
--
local letter_variants = {
  "normal",
  "bold",
  "italic",
  "bold-italic",
  "double-struck",
  "fraktur",
  "bold-fraktur",
  "script",
  "bold-script",
  "sans-serif",
  "bold-sans-serif",
  "sans-serif-italic",
  "sans-serif-bold-italic",
  "monospace",
  -- "initial",
  -- "tailed",
  -- "looped",
  -- "stretched"
}
local number_variants = {
  "normal",
  "bold",
  "sans-serif",
  "bold-sans-serif",
  "double-struck",
  "monospace",
}

local greek_variants = {
  "normal",
  "bold",
  "italic",
  "bold-italic",
  "bold-sans-serif",
  "sans-serif-bold-italic",
}

local function mathvariant (variant, char)
  return ('<mathml><mo mathvariant="%s">%s</mo></mathml>'):format(variant, char)
end

local function build_table (start, stop, variants, extras)
  local ptable = {}
  local ncols = #variants
  local maxcols = #letter_variants -- The one with the most variants
  local szcols = 1 / maxcols * 99 .. "%lw" -- 99% to avoid rounding errors causing line breaks
  local szfont = "0.8em"

  -- local header = {}
  -- for _, variant in ipairs(variants) do
  --   local cell = SU.ast.createCommand("cell", { halign = "left" }, { variant })
  --   table.insert(header, cell)
  -- end
  -- table.insert(ptable, SU.ast.createStructuredCommand("row", { background = "#f0f0f0" }, header))

  for letter = start, stop do
    if letter ~= 0x3A2 then -- invalid capital greek letter
      local row = {}
      local char = luautf8.char(letter)
      for _, variant in ipairs(variants) do
        local cell = SU.ast.createCommand("cell", { halign = "center" }, function ()
          SILE.call("font", { size = szfont })        
          return SILE.processString(mathvariant(variant, char), "xml")
        end)
        table.insert(row, cell)
      end
      local row = SU.ast.createStructuredCommand("row", {}, row)
      table.insert(ptable, row)
    end
  end
  if extras then
    for _, extra in ipairs(extras) do
      local row = {}
      for _, variant in ipairs(variants) do
        local cell = SU.ast.createCommand("cell", { halign = "center" }, function ()
          SILE.call("font", { size = szfont })        
          return SILE.processString(mathvariant(variant, luautf8.char(extra)), "xml")
        end)
        table.insert(row, cell)
      end
      local row = SU.ast.createStructuredCommand("row", {}, row)
      table.insert(ptable, row)
    end
  end
  ptable = SU.ast.createStructuredCommand("ptable", {
    cols = string.rep(szcols, ncols, " "),
--  header  = true
  }, ptable)
  return ptable
end

local function do_figure (start, stop, variants, caption, extras)
  local ptable = build_table(start, stop, variants, extras)
  local figure = SU.ast.createStructuredCommand("figure", {}, {
    SU.ast.createCommand("caption", {}, { caption }),
    ptable
  })
  SILE.process({ figure })
end

SILE.process({
  SU.ast.createCommand("include", { src ="mathvariant/latin.dj", shift_headings = 1 }),
})
do_figure(0x41, 0x41 + 25, letter_variants, "MathML variants for uppercase Latin")
do_figure(0x61, 0x61 + 25, letter_variants, "MathML variants for lowercase Latin")
SILE.process({
  SU.ast.createCommand("include", { src ="mathvariant/digits.dj", shift_headings = 1 }),
})
do_figure(0x30, 0x30 + 9, number_variants, "MathML variants for digits")
SILE.process({
  SU.ast.createCommand("include", { src ="mathvariant/greek.dj", shift_headings = 1 }),
})
-- Extras = capital theta symbol: U+03F4, nabla: U+2207
do_figure(0x391, 0x391 + 24, greek_variants, "MathML variants for uppercase Greek", { 0x3F4, 0x2207} )
-- Extras = theta variant: U+03D1, phi variant: U+03D5, pi variant: U+03D6,
-- kappa variant: U+03F0, rho variant: U+03F1, epsilon variant: U+03F5
do_figure(0x3b1, 0x3b1 + 24, greek_variants, "MathML variants for lowercase Greek", { 0x3D1, 0x3D5, 0x3D6, 0x3F0, 0x3F1, 0x3F5 })
