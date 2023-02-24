local utils = require("nvim-sessions.utils")
local config = require("nvim-sessions.options")
local commands = require("nvim-sessions.commands")
local ui = require("nvim-sessions.ui")

local M = {}

M.setup = function(opts)
  config.setup(opts)

  if config.options.autosave == true then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = vim.api.nvim_create_augroup("NvimSessionsAutoSave", { clear = true }),
      callback = function()
        require("nvim-sessions.core").update({ ask_confirmation = false })
      end,
    })
  end

  commands.setup()
end

do
  local available_commands = { "list", "new", "load", "update", "delete" }
  for _, v in pairs(available_commands) do
    M[v] = require("nvim-sessions.core")[v]
  end
end


M.list = function()
  local fzf = require("fzf-lua")
  return fzf.files({
    user_config = { get_session_file = utils.get_session_file },
    prompt = "Sessions:",
    file_icons = false,
    show_cwd_header = true,
    preview_opts = "nohidden",
    previewer = ui.session_previewer,
    winopts = config.options.fzf_winopts,
    cwd = config.options.sessions_dir,
    actions = {
      ["default"] = function(selected)
        M["load"]({ name = selected[1] })
      end,
      ["ctrl-x"] = { function(selected)
        M["delete"]({ name = selected[1] })
      end, fzf.actions.resume },
    },
  })
end



M.current_session_name = function()
  return utils.get_current_session_name()
end


-- excluded from builtin / auto-complete
M._excluded_meta = {
  "setup",
}


return M
