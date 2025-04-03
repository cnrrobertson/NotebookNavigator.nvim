local repls = {}

local utils = require "notebook-navigator.utils"

-- iron.nvim
---@diagnostic disable-next-line: unused-local
repls.iron = function(start_line, end_line, repl_args, _cell_marker)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  require("iron.core").send(nil, lines)

  return true
end

-- toggleterm
---@diagnostic disable-next-line: unused-local
repls.toggleterm = function(start_line, end_line, repl_args, cell_marker)
  local id = 1
  local trim_spaces = true
  if repl_args then
    id = repl_args.id or 1
    trim_spaces = (repl_args.trim_spaces == nil) or repl_args.trim_spaces
  end
  local current_window = vim.api.nvim_get_current_win()
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if not lines or not next(lines) then
    return
  end

  for _, line in ipairs(lines) do
    local l = trim_spaces and line:gsub("^%s+", ""):gsub("%s+$", "") or line
    require("toggleterm").exec(l, id)
  end

  -- Jump back with the cursor where we were at the beginning of the selection
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_set_current_win(current_window)

  vim.api.nvim_win_set_cursor(current_window, { cursor_line, cursor_col })

  return true
end

-- molten
---@diagnostic disable-next-line: unused-local
repls.molten = function(start_line, end_line, repl_args, cell_marker)
  local line_count = vim.api.nvim_buf_line_count(0)

  if line_count < (end_line + 1) then
    vim.api.nvim_buf_set_lines(0, end_line + 1, end_line + 1, false, { cell_marker, "" })
  end

  local ok, _ = pcall(vim.fn.MoltenEvaluateRange, start_line, end_line + 1)
  if not ok then
    vim.cmd "MoltenInit"
    return false
  end

  return true
end

-- nuiterm
repls.nuiterm = function(start_line, end_line, repl_args)
  local type = nil
  local num = nil
  local setup_cmd = nil
  if repl_args then
    type = repl_args.type
    num = repl_args.num
    setup_cmd = repl_args.setup_cmd
  end
  require("nuiterm").send_lines(start_line, end_line, type, num, setup_cmd)

  return true
end

-- jupyterm
repls.jupyterm = function(start_line, end_line, repl_args)
  local kernel = nil
  if repl_args then
    kernel = repl_args.kernel
  end
  require("jupyterm.execute").send_lines(kernel, start_line, end_line)

  return true
end

-- no repl
repls.no_repl = function(_) end

local get_repl = function(repl_provider)
  local available_repls = utils.available_repls
  local chosen_repl = nil
  if repl_provider == "auto" then
    for _, r in ipairs(available_repls) do
      chosen_repl = repls[r]
      break
    end
  else
    chosen_repl = repls[repl_provider]
  end

  -- Check if we actuall got out a supported repl
  if chosen_repl == nil then
    vim.notify("[NotebookNavigator] The provided repl, " .. repl_provider .. ", is not supported.")
    chosen_repl = repls["no_repl"]
  end

  return chosen_repl
end

return get_repl
