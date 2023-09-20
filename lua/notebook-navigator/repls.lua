local repls = {}

-- iron.nvim
repls.iron = function(start_line, end_line, repl_args)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, 0)
  require("iron.core").send(nil, lines)
end

-- no repl
repls.no_repl = function(_)
  vim.notify "[Notebook Navigator] No supported repl plugin available"
end

local has_iron, _ = pcall(require, "iron")
local repl
if has_iron then
  repl = repls["iron"]
else
  repl = repls["no_repl"]
end
return repl
