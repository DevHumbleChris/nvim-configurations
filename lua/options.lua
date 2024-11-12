-- Load default NvChad options
require "nvchad.options"

-- Create utility function for making directories
local function mkdir(path)
  local is_windows = vim.fn.has('win32') == 1
  local p = vim.fn.expand(path)
  if vim.fn.isdirectory(p) == 0 then
    vim.fn.mkdir(p, 'p')
  end
end

-- Define and create swap directory
local swap_dir = vim.fn.stdpath('data') .. '/swap'
mkdir(swap_dir)

-- Define and create undo directory
local undo_dir = vim.fn.stdpath('data') .. '/undo'
mkdir(undo_dir)

-- Set up options
local opt = vim.opt

-- Swap file configuration
opt.swapfile = true                -- Keep swap files enabled for recovery
opt.directory = swap_dir           -- Set swap directory
opt.updatetime = 300               -- Faster swap file writing
opt.updatecount = 100              -- Write to swap file after 100 chars

-- Backup configuration
opt.backup = false                 -- Don't keep backup files
opt.writebackup = true            -- Make backup before overwriting file
opt.backupcopy = "auto"           -- Let OS decide how to backup

-- Persistent undo configuration
opt.undofile = true               -- Enable persistent undo
opt.undodir = undo_dir            -- Set undo directory
opt.undolevels = 1000             -- Maximum number of changes
opt.undoreload = 10000            -- Maximum lines to save for undo

-- Auto save on focus lost
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.api.nvim_command('silent! update')
    end
  end,
})

-- Command to clear swap files
vim.api.nvim_create_user_command('SwapClear', function()
  local swapfiles = vim.fn.glob(swap_dir .. '/*', true, true)
  for _, file in ipairs(swapfiles) do
    vim.fn.delete(file)
  end
  print("Cleared all swap files")
end, {})

-- Auto-clean old swap files on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local swapfiles = vim.fn.glob(swap_dir .. '/*', true, true)
    local current_time = os.time()
    
    for _, file in ipairs(swapfiles) do
      local modification_time = vim.fn.getftime(file)
      -- Delete swap files older than 3 days
      if current_time - modification_time > 60 * 60 * 24 * 3 then
        vim.fn.delete(file)
      end
    end
  end,
})