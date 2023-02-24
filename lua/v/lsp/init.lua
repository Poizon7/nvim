local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "v.lsp.mason"
require("v.lsp.handlers").setup()
