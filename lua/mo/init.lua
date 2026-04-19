local M = {}

---@param opts? mo.Config
function M.setup(opts)
  require("mo.config").setup(opts)
  require("mo.commands").register()

  if require("mo.config").values.auto_add then
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("mo_auto_add", { clear = true }),
      pattern = { "*.md", "*.mdx" },
      callback = function(ev)
        local path = vim.api.nvim_buf_get_name(ev.buf)
        if path ~= "" then
          require("mo.client").add({ vim.fn.fnamemodify(path, ":p") })
        end
      end,
    })
  end
end

return M
