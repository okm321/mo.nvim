local config = require("mo.config")

local M = {}

---@param args string[]
---@param opts? { on_exit?: fun(code: integer, stdout: string, stderr: string) }
function M.run(args, opts)
  opts = opts or {}
  local stdout_chunks = {}
  local stderr_chunks = {}

  vim.fn.jobstart(vim.list_extend({ "mo" }, args), {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout_chunks, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr_chunks, data)
      end
    end,
    on_exit = function(_, code)
      if opts.on_exit then
        local output = table.concat(stdout_chunks, "\n")
        local err = table.concat(stderr_chunks, "\n")
        vim.schedule(function()
          opts.on_exit(code, output, err)
        end)
      end
    end,
  })
end

---@return string[]
local function base_args()
  local args = { "--port", tostring(config.values.port) }
  if config.values.no_open then
    table.insert(args, "--no-open")
  end
  return args
end

---@param files string[]
---@param target? string
function M.add(files, target)
  if #files == 0 then
    return
  end
  local args = base_args()
  local t = target or config.values.target
  if t then
    vim.list_extend(args, { "--target", t })
  end
  vim.list_extend(args, files)
  M.run(args, {
    on_exit = function(code, _, err)
      if code == 0 then
        local label = #files == 1 and files[1] or #files .. " files"
        vim.notify("[mo] Added: " .. label, vim.log.levels.INFO)
      else
        local msg = "[mo] Failed to add files"
        if err and err ~= "" then
          msg = msg .. ": " .. vim.trim(err)
        end
        vim.notify(msg, vim.log.levels.ERROR)
      end
    end,
  })
end

---@param callback fun(ok: boolean, output: string)
function M.status(callback)
  M.run({ "--status", "--json", "--port", tostring(config.values.port) }, {
    on_exit = function(code, output)
      callback(code == 0, output)
    end,
  })
end

function M.shutdown()
  M.run({ "--shutdown", "--port", tostring(config.values.port) }, {
    on_exit = function(code, _)
      if code == 0 then
        vim.notify("[mo] Server stopped", vim.log.levels.INFO)
      end
    end,
  })
end

function M.restart()
  M.run({ "--restart", "--port", tostring(config.values.port) }, {
    on_exit = function(code, _)
      if code == 0 then
        vim.notify("[mo] Server restarted", vim.log.levels.INFO)
      end
    end,
  })
end

function M.clear()
  vim.ui.select({ "Yes", "No" }, {
    prompt = "Clear mo session? (stops server and removes all files)",
  }, function(choice)
    if choice ~= "Yes" then
      return
    end
    -- shutdown first, then clear (shutdown saves session, so clear must come after)
    M.run({ "--shutdown", "--port", tostring(config.values.port) }, {
      on_exit = function()
        local job_id = vim.fn.jobstart({ "mo", "--clear", "--port", tostring(config.values.port) }, {
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                vim.notify("[mo] Session cleared", vim.log.levels.INFO)
              else
                vim.notify("[mo] Failed to clear session", vim.log.levels.ERROR)
              end
            end)
          end,
        })
        vim.fn.chansend(job_id, "Y\n")
      end,
    })
  end)
end

---@param patterns string[]
---@param target? string
function M.watch(patterns, target)
  local args = base_args()
  local t = target or config.values.target
  if t then
    vim.list_extend(args, { "--target", t })
  end
  for _, p in ipairs(patterns) do
    vim.list_extend(args, { "--watch", p })
  end
  M.run(args)
end

return M
