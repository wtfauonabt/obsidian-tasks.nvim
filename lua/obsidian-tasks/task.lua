
local ignore_list = {".space"}

local M = {}

-- Utility function to check if a line is a property delimiter (---)
---@param line string
---@return boolean
local function is_property_delimiter(line)
    return line:find("^%-%-%-") ~= nil
end

-- Utility function to extract key and value from a property line
---@param line string
---@return string|nil, string|nil
local function parse_property_line(line)
    local key = line:match("([^%s]+)%s*:%s*")
    local value = line:match("[^%s]+%s*:%s*([^\n]+)")
    return key, value
end

-- Utility function to check if a value is empty or whitespace only
---@param value string|nil
---@return boolean
local function is_empty_value(value)
    return not value or value:match("^%s*$")
end

-- Utility function to parse bracket list format [[value]]
---@param value string
---@return string|nil
local function parse_bracket_list(value)
    -- Extract all bracket values and join them with commas
    local bracket_values = {}
    for bracket_value in value:gmatch("%[%[([^%]]+)%]%]") do
        table.insert(bracket_values, bracket_value)
    end
    
    if #bracket_values > 0 then
        return table.concat(bracket_values, ", ")
    end
    
    return nil
end

-- Utility function to parse multi-line bullet list
---@param lines table
---@param start_index number
---@return table, number
local function parse_bullet_list(lines, start_index)
    local list_values = {}
    local i = start_index
    
    while i <= #lines do
        local line = lines[i]
        
        -- Stop if we hit another property delimiter
        if is_property_delimiter(line) then
            break
        end
        
        local bullet_value = line:match("^%s*%-%s*(.+)")
        
        if bullet_value then
            local trimmed_value = bullet_value:gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(list_values, trimmed_value)
            i = i + 1
        else
            break
        end
    end
    
    return list_values, i
end

-- Utility function to process a single property value
---@param value string
---@return string
local function process_property_value(value)
    local bracket_match = parse_bracket_list(value)
    return bracket_match or value
end

-- Utility function to check if a file path is valid
---@param file_path string|nil
---@return boolean
local function is_valid_file_path(file_path)
    return file_path and file_path ~= ""
end

-- Utility function to split comma-separated values and trim whitespace
---@param property_value string
---@return table
local function split_property_values(property_value)
    local values = {}
    if property_value and type(property_value) == "string" then
        for value in property_value:gmatch("([^,]+)") do
            local trimmed_value = value:gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(values, trimmed_value)
        end
    end
    return values
end

-- Utility function to normalize filter value (handle metadata format)
---@param filter_item string|table
---@return string, boolean, string
local function normalize_filter_item(filter_item)
    if type(filter_item) == "string" then
        return filter_item, false, "~"  -- default to case sensitive, contains operator
    elseif type(filter_item) == "table" and filter_item.value then
        return filter_item.value, filter_item.case_insensitive or false, filter_item.operator or "~"
    else
        return tostring(filter_item), false, "~"
    end
end

-- Utility function to apply logical operator comparison
---@param property_value string
---@param filter_value string
---@param operator string
---@param case_insensitive boolean
---@return boolean
local function apply_logical_operator(property_value, filter_value, operator, case_insensitive)
    local search_text = case_insensitive and property_value:lower() or property_value
    local search_filter = case_insensitive and filter_value:lower() or filter_value
    
    if operator == "=" then
        -- Exact match
        return search_text == search_filter
    elseif operator == "!=" then
        -- Not equal
        return search_text ~= search_filter
    elseif operator == "~" then
        -- Contains (default behavior)
        return search_text:find(search_filter) ~= nil
    elseif operator == "!~" then
        -- Does not contain
        return search_text:find(search_filter) == nil
    elseif operator == "^" then
        -- Starts with
        return search_text:find("^" .. search_filter) ~= nil
    elseif operator == "!^" then
        -- Does not start with
        return search_text:find("^" .. search_filter) == nil
    elseif operator == "$" then
        -- Ends with
        return search_text:match(search_filter .. "$") ~= nil
    elseif operator == "!$" then
        -- Does not end with
        return search_text:match(search_filter .. "$") == nil
    else
        -- Default to contains for unknown operators
        return search_text:find(search_filter) ~= nil
    end
end

-- Utility function to check if any property value matches a single filter value
---@param property_values table
---@param filter_value string
---@param case_insensitive boolean
---@param operator string
---@return boolean
local function matches_single_filter(property_values, filter_value, case_insensitive, operator)
    for _, prop_val in ipairs(property_values) do
        if apply_logical_operator(prop_val, filter_value, operator, case_insensitive) then
            return true
        end
    end
    return false
end

-- Utility function to check if any property value matches any of multiple filter values
---@param property_values table
---@param filter_items table
---@return boolean
local function matches_multiple_filters(property_values, filter_items)
    for _, filter_item in ipairs(filter_items) do
        local filter_value, case_insensitive, operator = normalize_filter_item(filter_item)
        if matches_single_filter(property_values, filter_value, case_insensitive, operator) then
            return true
        end
    end
    return false
end

-- Utility function to check if a task property matches a filter
---@param property_value string
---@param filter_value string|table
---@return boolean
local function property_matches_filter(property_value, filter_value)
    local property_values = split_property_values(property_value)
    
    if type(filter_value) == "table" then
        return matches_multiple_filters(property_values, filter_value)
    else
        -- Single value, default to case sensitive, contains operator
        return matches_single_filter(property_values, filter_value, false, "~")
    end
end

-- Utility function to check if a task matches all filters
---@param task_properties table
---@param filters table
---@return boolean
local function task_matches_filters(task_properties, filters)
    for key, filter_value in pairs(filters) do
        if not task_properties[key] then
            return false
        end

        if not property_matches_filter(task_properties[key], filter_value) then
            return false
        end
    end
    return true
end

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

    -- Split content into lines for easier processing
    local lines = {}
    for line in task_content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local property_identifier_found = false
    local i = 1

    while i <= #lines do
        local line = lines[i]

        -- Check if the line starts with `---`
        if is_property_delimiter(line) then
            if property_identifier_found then
                break
            end
            property_identifier_found = true
            i = i + 1
            goto continue
        end

        if not property_identifier_found then
            i = i + 1
            goto continue
        end

        -- Parse property line
        local key, value = parse_property_line(line)

        if key then
            if is_empty_value(value) then
                -- Multi-line bullet list
                local list_values, new_index = parse_bullet_list(lines, i + 1)
                if #list_values > 0 then
                    task[key] = table.concat(list_values, ", ")
                end
                i = new_index
            else
                -- Single line value
                task[key] = process_property_value(value)
                i = i + 1
            end
        else
            i = i + 1
        end

        ::continue::
    end

    return task
end

--- Filter tasks based on the filters
---@param task_list table List of task file paths
---@param filters table Filter criteria. Supports multiple formats:
---   Simple single value: {Status = "Completed"}
---   Multiple values: {Status = {"Completed", "Closed"}}
---   With metadata: {Status = {{value = "Completed", case_insensitive = true}, "Closed"}}
---   With logical operators: {Status = {{value = "Completed", operator = "=", case_insensitive = false}}}
---   Mixed format: {Status = {"Completed", {value = "Closed", operator = "!=", case_insensitive = true}}}
---   Supported operators:
---   - "=" : Exact match
---   - "!=" : Not equal
---   - "~" : Contains (default)
---   - "!~" : Does not contain
---   - "^" : Starts with
---   - "!^" : Does not start with
---   - "$" : Ends with
---   - "!$" : Does not end with
---   Works with various property formats:
---   - Simple: Status: Completed
---   - Bracket list: Status: [[Closed]]
---   - Multi-line list: Status:\n  - Not Started\n  - In Progress
---@return table Filtered list of task file paths
M.filterTasks = function(task_list, filters)
    local filtered_task_list = {}

    for _, file_path in ipairs(task_list) do
        -- Skip if file_path is invalid
        if not is_valid_file_path(file_path) then
            goto continue
        end

        -- Get task properties
        local task_properties = M.getTaskProperties(file_path)

        -- Check if task matches all filters
        if task_matches_filters(task_properties, filters) then
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

