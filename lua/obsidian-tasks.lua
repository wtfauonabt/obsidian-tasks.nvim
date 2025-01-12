-- main module file
local module = require("obsidian-tasks.module")

---@class Config
---@field opt table Your config option
local config = {
    opt = {},
    vault_path = os.getenv('OBSIDIAN_VAULT_PATH') or "/default/path/to/vault",
    task_folder = "/task"
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})
    M.vault_path = config.vault_path or "/default/path/to/vault"
    M.task_folder = config.task_folder or "/tasks"
    -- Initialize your plugin with the provided configuration
end

M.search = function()
    local filters = {}
    return module.search(M.vault_path, M.task_folder, filters)
end

return M
