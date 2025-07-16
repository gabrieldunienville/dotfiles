local M = {}

M.layout = {
  main = {
    windows = {
      code = {},
      tools = {
        win_args = {
          position = 'right',
          width = 0.4,
        },
        buffers = {
          claude_code = {
            launch = function()
              vim.cmd 'terminal claude'
            end,
          },
          ipython = {
            launch = function()
              vim.cmd 'terminal uv run ipython'
            end,
          },
        },
      },
    },
  },
  terminals = {
    windows = {
      primary_terminal = {
        launch = function()
          vim.cmd 'terminal'
        end,
      },
    },
  },
  runner = {
    windows = {
      runner = {
        launch = function()
          vim.cmd 'terminal'
        end,
      },
    },
  },
}

---@class WinConfig
---@field tab_name string
---@field win_args? table<string, any>
---@field launch? fun():nil

---@class BufferConfig
---@field tab_name string
---@field win_name string
---@field launch? fun():nil

local win_items = {}
local buf_items = {}

for tab_name, tab_config in pairs(M.layout) do
  for win_name, win_config in pairs(tab_config.windows) do
    win_items[win_name] = {
      tab_name = tab_name,
      win_args = win_config.win_args,
      launch = win_config.launch,
    }
    if win_config.buffers then
      for buf_name, buf_config in pairs(win_config.buffers) do
        buf_items[buf_name] = {
          tab_name = tab_name,
          win_name = win_name,
          launch = buf_config.launch,
        }
      end
    end
  end
end

---@param win_name string
---@return WinConfig
function M.get_win_config(win_name)
  return win_items[win_name]
end

---@param buf_name string
---@return BufferConfig
function M.get_buf_config(buf_name)
  return buf_items[buf_name]
end

-- vim.print(win_items)
-- vim.print(buf_items)

M.primary_win_by_tab = {}
for key, value in pairs(win_items) do
  if value.win_args == nil then
    M.primary_win_by_tab[value.tab_name] = key
  end
end

return M
