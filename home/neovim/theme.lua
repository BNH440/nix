-- Name: kaf_dark
-- Description: converted from iterm2 colors

vim.cmd("clearjumps")
vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "kaf_dark"

local colors = {
  bg         = "#15142f",
  fg         = "#f0ebff",
  black      = "#15142f",
  red        = "#e36981",
  green      = "#8fbf9f",
  yellow     = "#e8c547",
  blue       = "#7b6fd9",
  magenta    = "#e070b8",
  cyan       = "#9aaee8",
  white      = "#c4c3ca",
  br_black   = "#646378",
  br_red     = "#ff8095",
  br_green   = "#a8d4b6",
  br_yellow  = "#f5d76e",
  br_blue    = "#9d8fff",
  br_magenta = "#ff8fd0",
  br_cyan    = "#bcc4ff",
  br_white   = "#ffffff",
  selection  = "#e19dce",
}

-- Terminal Colors
vim.g.terminal_color_0  = colors.black
vim.g.terminal_color_1  = colors.red
vim.g.terminal_color_2  = colors.green
vim.g.terminal_color_3  = colors.yellow
vim.g.terminal_color_4  = colors.blue
vim.g.terminal_color_5  = colors.magenta
vim.g.terminal_color_6  = colors.cyan
vim.g.terminal_color_7  = colors.white
vim.g.terminal_color_8  = colors.br_black
vim.g.terminal_color_9  = colors.br_red
vim.g.terminal_color_10 = colors.br_green
vim.g.terminal_color_11 = colors.br_yellow
vim.g.terminal_color_12 = colors.br_blue
vim.g.terminal_color_13 = colors.br_magenta
vim.g.terminal_color_14 = colors.br_cyan
vim.g.terminal_color_15 = colors.br_white

local highlights = {
  -- Original Base UI Highlights
  Normal       = { fg = colors.fg, bg = colors.bg },
  NormalFloat  = { fg = colors.fg, bg = colors.bg },
  Cursor       = { fg = colors.bg, bg = colors.selection },
  CursorLine   = { bg = colors.br_black },
  CursorColumn = { bg = colors.br_black },
  LineNr       = { fg = colors.br_black },
  CursorLineNr = { fg = colors.yellow, bold = true },
  Visual       = { fg = colors.bg, bg = colors.selection },
  Search       = { fg = colors.bg, bg = colors.yellow },
  IncSearch    = { fg = colors.bg, bg = colors.br_yellow },
  ColorColumn  = { bg = colors.br_black },
  SignColumn   = { bg = colors.bg },
  VertSplit    = { fg = colors.br_black },
  Pmenu        = { fg = colors.fg, bg = colors.br_black },
  PmenuSel     = { fg = colors.bg, bg = colors.selection },
  
  -- Traditional Vim Syntax Fallbacks
  Comment      = { fg = colors.br_black, italic = true },
  Constant     = { fg = colors.magenta },
  String       = { fg = colors.green },
  Character    = { fg = colors.green },
  Number       = { fg = colors.br_magenta },
  Boolean      = { fg = colors.br_magenta },
  Float        = { fg = colors.br_magenta },
  Identifier   = { fg = colors.fg },
  Function     = { fg = colors.blue },
  Statement    = { fg = colors.red },
  Conditional  = { fg = colors.br_red, italic = true },
  Repeat       = { fg = colors.br_red, italic = true },
  Label        = { fg = colors.br_red },
  Operator     = { fg = colors.cyan },
  Keyword      = { fg = colors.red },
  Exception    = { fg = colors.br_red },
  PreProc      = { fg = colors.yellow },
  Include      = { fg = colors.blue },
  Define       = { fg = colors.magenta },
  Macro        = { fg = colors.magenta },
  Type         = { fg = colors.yellow },
  StorageClass = { fg = colors.yellow },
  Structure    = { fg = colors.yellow },
  Typedef      = { fg = colors.yellow },
  Special      = { fg = colors.cyan },
  SpecialChar  = { fg = colors.br_cyan },
  Tag          = { fg = colors.cyan },
  Delimiter    = { fg = colors.fg },
  SpecialComment= { fg = colors.br_black, bold = true },
  Debug        = { fg = colors.br_red },
  Underlined   = { underline = true },
  Ignore       = { fg = colors.br_black },
  Error        = { fg = colors.br_white, bg = colors.red, bold = true },
  Todo         = { fg = colors.bg, bg = colors.yellow, bold = true },

  -- Diagnostics
  DiagnosticError = { fg = colors.red },
  DiagnosticWarn  = { fg = colors.yellow },
  DiagnosticInfo  = { fg = colors.blue },
  DiagnosticHint  = { fg = colors.cyan },

  -- Tree-sitter Granular Scopes (Neovim 0.9+)
  ["@comment"]               = { fg = colors.br_black, italic = true },
  ["@comment.documentation"] = { fg = colors.br_green, italic = true },
  
  ["@keyword"]               = { fg = colors.red },
  ["@keyword.control"]       = { fg = colors.br_red, italic = true },
  ["@keyword.control.return"]= { fg = colors.br_red, italic = true },
  ["@keyword.coroutine"]     = { fg = colors.br_red, italic = true },
  ["@keyword.operator"]      = { fg = colors.cyan },
  ["@keyword.function"]      = { fg = colors.red },
  ["@keyword.type"]          = { fg = colors.red },
  ["@keyword.modifier"]      = { fg = colors.br_red },
  
  ["@function"]              = { fg = colors.blue },
  ["@function.method"]       = { fg = colors.br_blue },
  ["@function.macro"]        = { fg = colors.magenta },
  ["@function.builtin"]      = { fg = colors.br_magenta },
  
  ["@type"]                  = { fg = colors.yellow },
  ["@type.builtin"]          = { fg = colors.br_yellow },
  ["@type.enum.variant"]     = { fg = colors.br_yellow },
  ["@type.interface"]        = { fg = colors.yellow, italic = true },
  
  ["@constructor"]           = { fg = colors.yellow },
  
  ["@variable"]              = { fg = colors.fg },
  ["@variable.builtin"]      = { fg = colors.magenta, italic = true },
  ["@variable.parameter"]    = { fg = colors.br_cyan },
  ["@variable.member"]       = { fg = colors.cyan },
  
  ["@property"]              = { fg = colors.cyan },
  ["@attribute"]             = { fg = colors.br_yellow },
  ["@label"]                 = { fg = colors.br_red },
  
  ["@module"]                = { fg = colors.white, italic = true },
  ["@namespace"]             = { fg = colors.white, italic = true },
  
  ["@string"]                = { fg = colors.green },
  ["@string.escape"]         = { fg = colors.br_cyan },
  ["@string.regexp"]         = { fg = colors.br_green },
  ["@string.special"]        = { fg = colors.br_green },
  ["@string.special.symbol"] = { fg = colors.yellow },
  
  ["@number"]                = { fg = colors.br_magenta },
  ["@number.float"]          = { fg = colors.br_magenta },
  ["@boolean"]               = { fg = colors.br_magenta },
  
  ["@constant"]              = { fg = colors.magenta },
  ["@constant.builtin"]      = { fg = colors.br_magenta },
  
  ["@operator"]              = { fg = colors.cyan },
  ["@punctuation.delimiter"] = { fg = colors.br_black },
  ["@punctuation.bracket"]   = { fg = colors.fg },
  ["@punctuation.special"]   = { fg = colors.magenta },
  
  ["@tag"]                   = { fg = colors.cyan },
  ["@tag.attribute"]         = { fg = colors.blue },
  ["@tag.delimiter"]         = { fg = colors.br_black },
  
  ["@markup.link.label"]     = { fg = colors.br_blue, italic = true },
  ["@markup.link.url"]       = { fg = colors.blue, italic = true },
}

for group, settings in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, settings)
end