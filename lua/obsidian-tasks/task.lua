
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

        if not property_identifier_found then
            goto continue
        end

        local key = line:match("([^%s]+)%s*:%s*")
        local value = line:match("[^%s]+%s*:%s*([^\n]+)")

        -- Only add to task table if key is not nil
        if key then
            task[key] = value
        end

        ::continue::
    end

    return task
end

--- Filter tasks based on the filters
---@param task_list table List of task file paths
---@param filters table Filter criteria. Supports both single values and arrays:
---   Single value: {Status = "Completed"}
---   Multiple values: {Status = {"Completed", "Closed"}}
---@return table Filtered list of task file paths
M.filterTasks = function(task_list, filters)
    local filtered_task_list = {}

    for _, file_path in ipairs(task_list) do

        -- Skip if file_path is nil or empty
        if not file_path or file_path == "" then
            goto continue
        end

        -- Get task properties
        local task_properties = M.getTaskProperties(file_path)

        -- Loop filter and see if task matches
        local task_matches = true
        for key, filter_value in pairs(filters) do
            if task_properties[key] then
                local property_value = task_properties[key]
                local matches_filter = false

                -- Check if filter_value is an array (table)
                if type(filter_value) == "table" then
                    -- Multiple values: check if property matches any of the values
                    for _, value in ipairs(filter_value) do
                        if property_value:find(value) then
                            matches_filter = true
                            break
                        end
                    end
                else
                    -- Single value: check if property contains the value
                    matches_filter = property_value:find(filter_value) ~= nil
                end

                if not matches_filter then
                    task_matches = false
                    break
                end
            else
                -- If task doesn't have the property, it doesn't match
                task_matches = false
                break
            end
        end

        -- Add the file to the task list if it matches all filters
        if task_matches then
            table.insert(filtered_task_list, file_path)
        end
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

