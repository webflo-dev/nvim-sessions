---@diagnostic disable: deprecated
local core = require("nvim-sessions.core")
local utils = require("nvim-sessions.utils")


local M = {}

local run_command = function(args)
  local user_opts = args or {}
  if not user_opts.cmd then
    utils.notify("missing command")
    return
  end

  local cmd = user_opts.cmd
  local opts = user_opts.opts or {}

  if core[cmd] then
    core[cmd](opts)
  else
    utils.notify(string.format("invalid command '%s'", cmd))
  end
end

local load_command = function(cmd, ...)
  local args = { ... }
  if cmd == nil then
    run_command({ cmd = "load" })
    return
  end

  local user_opts = {
    cmd = cmd,
    opts = {},
  }

  for _, arg in ipairs(args) do
    local param = vim.split(arg, "=")
    user_opts.opts[param[1]] = param[2]
  end

  run_command(user_opts)
end

M.setup = function()
  vim.api.nvim_create_user_command("Session", function(cmdOpts)
    load_command(unpack(cmdOpts.fargs))
  end,
    {
      nargs = "*",
      complete = function(_, cmdLine)
        vim.tbl_filter(function(key)
          if require("nvim-sessions.init")._excluded_meta[key] then
            return false
          end
          return true
        end, vim.tbl_keys(require("nvim-sessions.init")))

        local available_commands = vim.tbl_keys(require("nvim-sessions.init"))
        local l = vim.split(cmdLine, "%s+")
        local n = #l - 2

        if n == 0 then
          return vim.tbl_filter(function(val)
            return vim.startswith(val, l[2])
          end, available_commands)
        end
      end,
    }
  )
end

return M
