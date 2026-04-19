local M = {}

---@class mo.Config
---@field port? integer
---@field no_open? boolean
---@field auto_add? boolean
---@field target? string
local defaults = {
  port = 6275,
  no_open = false,
  auto_add = false,
  target = nil,
}

M.values = vim.deepcopy(defaults)

---@param opts? mo.Config
function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M
