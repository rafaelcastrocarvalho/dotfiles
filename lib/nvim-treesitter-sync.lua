-- Install the treesitter parsers the config declares, and block until done.
--
-- The plugin's own config calls require('nvim-treesitter').install(...), but
-- that is async: a headless `nvim +qa` exits before a single parser is built,
-- which leaves a freshly bootstrapped machine with no highlighting until the
-- first real nvim session gets around to it.
--
-- The language list is read back out of the lazy spec rather than duplicated
-- here, so pkg/nvim/.../lua/plugins/treesitter.lua stays the single source of
-- truth. Everything is pcall-guarded: these are plugin internals, and a
-- bootstrap must not fail because they moved.

local TIMEOUT_MS = 10 * 60 * 1000

local ok, lazy_config = pcall(require, "lazy.core.config")
if not ok then
  print("skip: lazy.nvim not loaded")
  return
end

local plugin = lazy_config.plugins["nvim-treesitter"]
if not plugin then
  print("skip: nvim-treesitter is not in the lazy spec")
  return
end

local opts_ok, opts = pcall(function()
  return require("lazy.core.plugin").values(plugin, "opts", false)
end)
local langs = (opts_ok and opts and opts.ensure_installed) or {}
if #langs == 0 then
  print("skip: no ensure_installed languages declared")
  return
end

local ts_ok, ts = pcall(require, "nvim-treesitter")
if not ts_ok then
  print("skip: nvim-treesitter not loadable")
  return
end

local task_ok, task = pcall(ts.install, langs)
if not task_ok or type(task) ~= "table" or not task.wait then
  print("skip: install() did not return a waitable task")
  return
end

local wait_ok, err = pcall(task.wait, task, TIMEOUT_MS)
if not wait_ok then
  print("warn: parser install did not finish: " .. tostring(err))
  return
end

print(("installed %d parsers"):format(#vim.api.nvim_get_runtime_file("parser/*.so", true)))
