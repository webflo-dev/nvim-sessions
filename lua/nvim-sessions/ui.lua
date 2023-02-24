local builtin_ok, builtin = pcall(require, "fzf-lua.previewer.builtin")
if not builtin_ok then
  return
end


local session_files = function(file)
  local lines = {}
  local cwd, cwd_pat = "", "^cd%s*"
  local buf_pat = "^badd%s*%+%d+%s*"
  for line in io.lines(file) do
    if string.find(line, cwd_pat) then
      cwd = line:gsub("%p", "%%%1")
    end
    if string.find(line, buf_pat) then
      lines[#lines + 1] = line
    end
  end
  local buffers = {}
  for k, v in pairs(lines) do
    buffers[k] = v:gsub(buf_pat, ""):gsub(cwd:gsub("cd%s*", ""), ""):gsub("^/?%.?/", "")
  end
  return buffers
end


--- extend fzf builtin previewer
local M = {}

M.session_previewer = builtin.base:extend()

M.session_previewer.new = function(self, o, opts, fzf_win)
  M.session_previewer.super.new(self, o, opts, fzf_win)
  setmetatable(self, M.session_previewer)
  return self
end

M.session_previewer.populate_preview_buf = function(self, entry_str)
  local tmpbuf = self:get_tmp_buffer()
  local files = session_files(self.opts.user_config.get_session_file(entry_str))

  vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, files)
  self:set_preview_buf(tmpbuf)
  self.win:update_scrollbar()
end

M.session_previewer.gen_winopts = function(self)
  local new_winopts = {
    wrap = false,
    number = false,
  }
  return vim.tbl_extend("force", self.winopts, new_winopts)
end

return M
