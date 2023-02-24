-- Inspired by
-- https://alpha2phi.medium.com/neovim-for-beginners-session-c287a431389e
-- https://github.com/gennaro-tedesco/nvim-sessions

local config = require("nvim-sessions.options")

local default_global_variable = "nvim-sessions"

local M = {}


M.notify = function(msg, title)
  vim.notify(msg, vim.log.levels.INFO, (title ~= nil and { title = title }) or nil)
end


-- get current session name
M.get_current_session_name = function()
  return vim.g[default_global_variable]
end
-- set current session name
M.set_current_session_name = function(name)
  vim.g[default_global_variable] = name
end


-- Session file hepers
M.get_session_file = function(session_name)
  return vim.fn.fnameescape(config.options.sessions_dir .. "/" .. (session_name or M.get_current_session_name()))
end


-- create or update nvim session file
M.make_session = function(session_name)
  local tmp = vim.o.sessionoptions
  vim.o.sessionoptions = table.concat(config.options.sessionoptions, ",")

  local session_file = M.get_session_file(session_name)
  vim.cmd("mksession! " .. session_file)

  vim.o.sessionoptions = tmp
  M.set_current_session_name(session_name)
end

-- load nvim session file
M.source_session = function(session_name)
  local session_file = M.get_session_file(session_name)
  vim.cmd("source " .. session_file)
  M.set_current_session_name(session_name)
end

-- delete nvim session file
M.delete_session = function(session_name)
  local session_file = M.get_session_file(session_name)
  os.remove(session_file)
end

-- close all buffers
M.clean_buffers_before_load = function()
  local buf_list = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_buf_get_option(buf, "buflisted")
        and vim.api.nvim_buf_get_option(buf, "modifiable")
    -- and not is_in_list(vim.api.nvim_buf_get_option(buf, "filetype"), config.options.autoswitch.exclude_ft)
  end, vim.api.nvim_list_bufs())
  for _, buf in pairs(buf_list) do
    vim.cmd("bd " .. buf)
  end
end

return M
