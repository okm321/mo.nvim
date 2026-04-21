local client = require("mo.client")

local M = {}

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("[mo] No file in current buffer", vim.log.levels.WARN)
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

local function is_markdown(path)
  return path:match("%.md$") or path:match("%.mdx$")
end

function M.add(args)
  local target = args.fargs[1]
  local path = current_file()
  if not path then
    return
  end
  if not is_markdown(path) then
    vim.notify("[mo] Not a Markdown file: " .. path, vim.log.levels.WARN)
    return
  end
  client.add({ path }, target)
end

function M.add_dir(args)
  local dir = args.fargs[1]
  if not dir then
    local bufname = vim.api.nvim_buf_get_name(0)
    dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h") or vim.fn.getcwd()
  end
  dir = vim.fn.fnamemodify(dir, ":p")
  local files = vim.fn.globpath(dir, "**/*.md", false, true)
  local mdx = vim.fn.globpath(dir, "**/*.mdx", false, true)
  vim.list_extend(files, mdx)

  if #files == 0 then
    vim.notify("[mo] No Markdown files found in " .. dir, vim.log.levels.WARN)
    return
  end

  client.add(files, args.fargs[2])
end

function M.status()
  client.status(function(ok, output)
    if not ok then
      vim.notify("[mo] Server not running", vim.log.levels.WARN)
      return
    end

    local lines = vim.split(output, "\n", { trimempty = true })
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "json"
    vim.bo[buf].modifiable = false

    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(#lines + 2, vim.o.lines - 4)
    vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
      style = "minimal",
      border = "rounded",
      title = " mo status ",
      title_pos = "center",
    })

    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  end)
end

function M.shutdown()
  client.shutdown()
end

function M.restart()
  client.restart()
end

function M.clear()
  client.clear()
end

function M.watch(args)
  local patterns = {}
  local target = nil
  local i = 1
  while i <= #args.fargs do
    if args.fargs[i] == "-t" and args.fargs[i + 1] then
      target = args.fargs[i + 1]
      i = i + 2
    else
      table.insert(patterns, args.fargs[i])
      i = i + 1
    end
  end
  if #patterns == 0 then
    patterns = { "**/*.md" }
  end
  client.watch(patterns, target)
end

function M.add_diff(args)
  local target = args.fargs[1]
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("[mo] Not a git repository", vim.log.levels.WARN)
    return
  end

  -- staged + unstaged + untracked
  local diff_files = vim.fn.systemlist("git diff --name-only HEAD 2>/dev/null")
  local untracked = vim.fn.systemlist("git ls-files --others --exclude-standard 2>/dev/null")
  vim.list_extend(diff_files, untracked)

  local files = {}
  local seen = {}
  for _, f in ipairs(diff_files) do
    local full = git_root .. "/" .. f
    if not seen[full] and is_markdown(f) then
      seen[full] = true
      table.insert(files, full)
    end
  end

  if #files == 0 then
    vim.notify("[mo] No changed Markdown files", vim.log.levels.INFO)
    return
  end

  client.add(files, target)
end

function M.register()
  vim.api.nvim_create_user_command("MoAdd", M.add, {
    nargs = "?",
    desc = "Add current Markdown file to mo (optional: target group)",
  })
  vim.api.nvim_create_user_command("MoAddDir", M.add_dir, {
    nargs = "*",
    desc = "Add directory to mo (optional: path, target)",
    complete = "dir",
  })
  vim.api.nvim_create_user_command("MoStatus", M.status, {
    desc = "Show mo server status",
  })
  vim.api.nvim_create_user_command("MoShutdown", M.shutdown, {
    desc = "Shut down mo server",
  })
  vim.api.nvim_create_user_command("MoRestart", M.restart, {
    desc = "Restart mo server",
  })
  vim.api.nvim_create_user_command("MoClear", M.clear, {
    desc = "Clear mo session",
  })
  vim.api.nvim_create_user_command("MoWatch", M.watch, {
    nargs = "*",
    desc = "Watch glob patterns (e.g., :MoWatch **/*.md -t docs)",
  })
  vim.api.nvim_create_user_command("MoAddDiff", M.add_diff, {
    nargs = "?",
    desc = "Add changed Markdown files (git diff) to mo",
  })
  vim.api.nvim_create_user_command("MoPick", function(args)
    require("mo.picker").pick(args.fargs[1])
  end, {
    nargs = "?",
    desc = "Pick Markdown files to add to mo",
  })
end

return M
