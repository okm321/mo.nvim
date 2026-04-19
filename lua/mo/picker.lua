local client = require("mo.client")

local M = {}

---@param target? string
function M.pick(target)
  local ok_snacks, _ = pcall(require, "snacks.picker")
  if ok_snacks then
    M.snacks_pick(target)
    return
  end

  local ok_telescope, _ = pcall(require, "telescope")
  if ok_telescope then
    M.telescope_pick(target)
    return
  end

  local ok_fzf, _ = pcall(require, "fzf-lua")
  if ok_fzf then
    M.fzf_lua_pick(target)
    return
  end

  vim.notify("[mo] snacks.nvim, telescope.nvim, or fzf-lua is required for :MoPick", vim.log.levels.ERROR)
end

local find_cmd = {
  "find", ".", "-type", "f",
  "(", "-name", "*.md", "-o", "-name", "*.mdx", ")",
  "-not", "-path", "*/node_modules/*",
  "-not", "-path", "*/.git/*",
}

---@param target? string
function M.snacks_pick(target)
  local Snacks = require("snacks")

  Snacks.picker({
    title = "mo: Add Markdown files",
    finder = function(_, ctx)
      return require("snacks.picker.source.proc").proc(ctx:opts({
        cmd = find_cmd[1],
        args = vim.list_slice(find_cmd, 2),
        cwd = vim.fn.getcwd(),
        transform = function(item)
          item.file = item.text
        end,
      }), ctx)
    end,
    format = function(item, _)
      local path = item.text or ""
      local dir = vim.fn.fnamemodify(path, ":h")
      local name = vim.fn.fnamemodify(path, ":t")
      return {
        { "  " },
        { name, "SnacksPickerFile" },
        { "  " },
        { dir, "SnacksPickerComment" },
      }
    end,
    win = {
      input = {
        keys = {
          ["<C-a>"] = { "select_all", mode = { "i", "n" } },
        },
      },
    },
    confirm = function(picker, _)
      local selected = picker:selected({ fallback = true })
      picker:close()

      local files = {}
      for _, item in ipairs(selected) do
        local path = item.text or item[1]
        if path then
          table.insert(files, vim.fn.fnamemodify(path, ":p"))
        end
      end

      if #files > 0 then
        client.add(files, target)
      end
    end,
  })
end

---@param target? string
function M.telescope_pick(target)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "mo: Add Markdown files",
      finder = finders.new_oneshot_job(find_cmd, { cwd = vim.fn.getcwd() }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local function send_selected()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selections = picker:get_multi_selection()

          if #selections == 0 then
            local entry = action_state.get_selected_entry()
            if entry then
              selections = { entry }
            end
          end

          actions.close(prompt_bufnr)

          local files = {}
          for _, entry in ipairs(selections) do
            local path = entry[1] or entry.value
            table.insert(files, vim.fn.fnamemodify(path, ":p"))
          end

          if #files > 0 then
            client.add(files, target)
          end
        end

        actions.select_default:replace(send_selected)

        map("i", "<C-a>", function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          for _, entry in ipairs(picker.finder.results) do
            picker:add_selection(entry)
          end
        end)

        return true
      end,
    })
    :find()
end

---@param target? string
function M.fzf_lua_pick(target)
  local fzf = require("fzf-lua")

  fzf.files({
    prompt = "mo: Add Markdown files> ",
    cmd = table.concat(find_cmd, " "),
    actions = {
      ["default"] = function(selected)
        local files = {}
        for _, item in ipairs(selected) do
          local path = fzf.path.entry_to_file(item).path
          table.insert(files, vim.fn.fnamemodify(path, ":p"))
        end
        if #files > 0 then
          client.add(files, target)
        end
      end,
    },
  })
end

return M
