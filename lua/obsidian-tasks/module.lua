
-- Importing libraries
local task = require("obsidian-tasks.task")
local telescope = require("obsidian-tasks.telescope")

---@class ObsidianTasks
local M = {}

-- Function to search tasks based on filters
M.search = function(vault_path, task_folder, filters)
    local search_path = vault_path .. task_folder

    -- List files in the task folder and parse to telescope
    local task_list = task.getTaskList(search_path)

    -- Filter tasks based on the filters
    task_list = task.filterTasks(task_list, filters)

    -- Call telescope to find tasks
    telescope.taskFinder(task_list)
end

return M
