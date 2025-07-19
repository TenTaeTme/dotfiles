local conform = require 'conform'

conform.setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    javascriptreact = { 'prettier' },
    c = { 'clang-format' },
    go = { 'goimports', 'gofmt' },
    ['_'] = { 'prettier' },
  },
  format_on_save = {
    enabled = true,
    timeout_ms = 300,
  },
  format_after_save = {
    lsp_fallback = true,
  },
  -- Optionally set a default formatter
  default_formatters = {
    'prettier',
  },
}
