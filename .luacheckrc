std = "luajit"
cache = true
codes = true

globals = {
  "vim",
}

self = false

-- Ignore unused "self" parameter warnings (common in Lua OO)
ignore = {
  "212/self",
  "631", -- line is too long
}
