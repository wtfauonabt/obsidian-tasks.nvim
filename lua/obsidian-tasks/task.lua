
local ignore_list = {".space"}

local M = {}

-- Read Markdown Properties in the start of the Task by finding the first line that starts with `---` and ends with `---`
---@param task_path string
---@return table
M.getTaskProperties = function(task_path)
    local task = {}
    local task_file = io.open(task_path, "r")

    -- Return empty table if file does not exist
    if not task_file then
        return task
    end

    local task_content = task_file:read("*a")
    task_file:close()

    -- Return empty table if content is empty
    if not task_content then
        print("Content not found: " .. task_path)
        return task
    end

    -- Find the first line that starts with `---` and ends with `---`
    local task_properties = nil
    local property_identifier_found = false
    for line in task_content:gmatch("[^\n]+") do
        --- Check if the line starts with `---`
        if line:find("^%-%-%-") then
            if property_identifier_found then
                break
            end

            property_identifier_found = true
            goto continue
        end

        local key = line:match("([^%s]+)%s*:%s*")
        local value = line:match("[^%s]+%s*:%s*([^\n]+)")

        task[key] = value

        ::continue::
    end

    return task
end

--- Filter tasks based on the filters
M.filterTasks = function(task_list, filters)
    local filtered_task_list = {}

    for _, file_path in ipairs(task_list) do
        -- Get task properties
        local task_properties = M.getTaskProperties(file_path)

        -- Loop filter and see if task matches
        for key, value in pairs(filters) do
            if task_properties[key] == value then
                goto continue
            end
        end

        -- Add the file to the task list
        table.insert(filtered_task_list, file_path)
        ::continue::
    end

    return filtered_task_list
end

---Get the list of tasks
---@return table
M.getTaskList = function(path)
    local task_list = {}

    -- List files in the path
    for _, file in ipairs(vim.fn.readdir(path)) do

        -- Skip if the file is in the ignore list
        if vim.tbl_contains(ignore_list, file) then
            goto continue
        end

        local file_path = path .. '/' .. file

        -- Add the file to the task list
        table.insert(task_list, file_path)

        ::continue::
    end

    return task_list
end

return M

