local config = require("nvim-sessions.options")
local utils = require("nvim-sessions.utils")
local ui = require("nvim-sessions.ui")

local M = {}

local function get_default_session_name()
	if vim.fn.trim(vim.fn.system("git rev-parse --is-inside-work-tree")) == "true" then
		return vim.fn.trim(vim.fn.system("basename `git rev-parse --show-toplevel`"))
	end

	return vim.fs.basename(vim.fn.getcwd())
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
				M.load({ name = selected[1] })
			end,
			["ctrl-x"] = {
				function(selected)
					M.delete({ name = selected[1] })
				end,
				fzf.actions.resume,
			},
		},
	})
end

M.load = function(opts)
	if not opts then
		opts = {}
	end
	if not opts.name then
		utils.notify("please, provide a name")
		return
	end

	M.update({ ask_confirmation = false })

	local session_name = opts.name
	utils.clean_buffers_before_load()
	utils.source_session(session_name)
	utils.notify("session restored", session_name)
end

M.new = function(opts)
	if not opts then
		opts = {}
	end

	local session_name = opts.name or nil

	local function create_session(_name)
		if _name then
			utils.make_session(_name)
			utils.notify("session created", _name)
		end
	end

	if session_name == nil then
		vim.ui.input({ prompt = "Session name: ", default = get_default_session_name() }, create_session)
	else
		create_session(session_name)
	end
end

M.update = function(opts)
	if not opts then
		opts = {}
	end
	if opts.ask_confirmation == nil then
		opts.ask_confirmation = true
	end

	local current_session = utils.get_current_session_name()
	if current_session ~= nil then
		local confirm = 1
		if opts.ask_confirmation == true then
			confirm = vim.fn.confirm("Overwrite session? " .. current_session, "&Yes\n&No", 2)
		end
		if confirm == 1 then
			utils.make_session(current_session)
			utils.notify("session updated", current_session)
		end
	end
end

M.delete = function(opts)
	if not opts then
		opts = {}
	end
	if not opts.name then
		utils.notify("please, provide a name")
		return
	end

	local session_name = opts.name
	local confirm = vim.fn.confirm("Delete session? " .. session_name, "&Yes\n&No", 2)
	if confirm == 1 then
		utils.delete_session(session_name)
		utils.notify("session deleted", session_name)
		if utils.get_current_session_name() == vim.fs.basename(session_name) then
			utils.set_current_session_name(nil)
		end
	end
end

return M
