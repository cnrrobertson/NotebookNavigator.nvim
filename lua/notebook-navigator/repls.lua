local repls = {}

-- iron.nvim
repls.iron = function(start_line, end_line, repl_args)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, 0)
  require("iron.core").send(nil, lines)
end

-- toggleterm
repls.toggleterm = function(start_line, end_line, repl_args)
  local id = 1
  local trim_spaces = true
  if repl_args then
    id = repl_args.id or 1
    trim_spaces = repl_args.trim_spaces or true
  end
  local current_window = vim.api.nvim_get_current_win()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, 0)

  if not lines or not next(lines) then return end

  for _, line in ipairs(lines) do
    local l = trim_spaces and line:gsub("^%s+", ""):gsub("%s+$", "") or line
    require("toggleterm").exec(l, id)
  end

  -- Jump back with the cursor where we were at the beginning of the selection
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_set_current_win(current_window)

  vim.api.nvim_win_set_cursor(current_window, { cursor_line, cursor_col })
end

-- no repl
repls.no_repl = function(_)
  vim.notify "[Notebook Navigator] No supported repl plugin available"
end

local has_iron, _ = pcall(require, "iron")
local has_toggleterm, _ = pcall(require, "toggleterm")
local repl
if has_iron then
  repl = repls["iron"]
elseif has_toggleterm then
  repl = repls["toggleterm"]
else
  repl = repls["no_repl"]
end
return repl
