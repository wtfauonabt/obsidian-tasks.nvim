local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"

---@class TelescopeModule
local M = {}

-- Entry maker for tasks
local function taskEntryMaker(entry)
    return {
        value = entry,
        display = entry:match( "([^/]+)$" ),
        ordinal = entry,
    }
end

-- Custom finder function for Telescope
M.taskFinder = function(task_list)
    --opts = opts or {}
    local opts = {}

    pickers.new(opts, {
        prompt_title = "Obsidian Tasks",
        finder = finders.new_table {
            results = task_list,
            entry_maker =  taskEntryMaker,
        },
        file_ignore_patterns = {".space"},
        sorter = conf.generic_sorter(opts),
        previewer = previewers.cat.new(opts),
    }):find()
end

return M
