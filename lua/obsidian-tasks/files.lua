
local M = {}

---@return table
M.ls = function(path)
    local file_list = {}

    -- List files in the path
    for _, file in ipairs(vim.fn.readdir(path)) do
        table.insert(file_list, path .. '/' .. file)
    end

    return file_list
end

return M

