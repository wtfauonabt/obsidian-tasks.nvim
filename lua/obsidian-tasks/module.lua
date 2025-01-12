
-- Importing libraries
local files = require("obsidian-tasks.files")
local telescope = require("obsidian-tasks.telescope")

---@class ObsidianTasks
local M = {}

-- Function to search tasks based on filters
M.search = function(vault_path, task_folder, filters)
    local search_path = vault_path .. task_folder

    -- List files in the task folder and parse to telescope
    local file_list = files.ls(search_path)

    -- Call telescope to find tasks
    telescope.task_finder(file_list)
end

return M
