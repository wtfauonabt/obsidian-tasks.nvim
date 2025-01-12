local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"

---@class TelescopeModule
local M = {}

-- Custom finder function for Telescope
M.task_finder = function(file_list)
    --opts = opts or {}
    local opts = {}
    pickers.new(opts, {
        prompt_title = "Obsidian Tasks",
        finder = finders.new_table {
            results = file_list
        },
        file_ignore_patterns = {".space"},
        sorter = conf.generic_sorter(opts),
        previewer = previewers.cat.new(opts),
    }):find()
end

return M
