-- Test helper utilities for obsidian-tasks.nvim

local M = {}

-- Helper function to create temporary test files
function M.create_test_file(path, content)
    local lines = {}
    if type(content) == "string" then
        lines = vim.split(content, "\n")
    elseif type(content) == "table" then
        lines = content
    else
        error("Content must be string or table")
    end
    
    vim.fn.writefile(lines, path)
    return path
end

-- Helper function to create temporary test directory
function M.create_test_dir(path)
    vim.fn.mkdir(path, "p")
    return path
end

-- Helper function to cleanup test files/directories
function M.cleanup_test_path(path)
    vim.fn.delete(path, "rf")
end

-- Helper function to create sample task files with different formats
function M.create_sample_tasks(test_dir)
    local tasks = {}
    
    -- Simple format task
    tasks.simple = test_dir .. "/simple.md"
    M.create_test_file(tasks.simple, [[
---
Status: Completed
Priority: High
Assignee: John Doe
---

# Simple Task
This is a simple task with basic properties.
]])
    
    -- Bracket list format task
    tasks.bracket = test_dir .. "/bracket.md"
    M.create_test_file(tasks.bracket, [[
---
Status: [[Closed]]
Tags: [[Important]], [[Urgent]]
Priority: [[Medium]]
---

# Bracket Task
This task uses bracket list format.
]])
    
    -- Bullet list format task
    tasks.bullet = test_dir .. "/bullet.md"
    M.create_test_file(tasks.bullet, [[
---
Status:
  - Not Started
  - In Progress
Tags:
  - Development
  - Testing
Priority: Low
---

# Bullet Task
This task uses bullet list format.
]])
    
    -- Mixed format task
    tasks.mixed = test_dir .. "/mixed.md"
    M.create_test_file(tasks.mixed, [[
---
Status: Completed
Priority: [[High]]
Tags:
  - Important
  - Done
Assignee: Jane Smith
Due: 2024-01-15
---

# Mixed Task
This task has mixed property formats.
]])
    
    -- Case variations task
    tasks.case_variations = test_dir .. "/case_variations.md"
    M.create_test_file(tasks.case_variations, [[
---
Status: completed
Priority: HIGH
Tags: [[Important]], [[URGENT]]
Assignee: bob wilson
---

# Case Variations Task
This task has different case variations.
]])
    
    -- Complex task with multiple properties
    tasks.complex = test_dir .. "/complex.md"
    M.create_test_file(tasks.complex, [[
---
Status: In Progress
Priority: High
Tags:
  - Development
  - Frontend
  - React
Assignee: Alice Johnson
Due: 2024-02-01
Created: 2024-01-01
Updated: 2024-01-15
---

# Complex Task
This is a complex task with many properties.
]])
    
    return tasks
end

-- Helper function to create sample filters for testing
function M.create_sample_filters()
    return {
        -- Simple filters
        simple_status = {Status = "Completed"},
        simple_priority = {Priority = "High"},
        
        -- Multiple value filters
        multiple_status = {Status = {"Completed", "Closed"}},
        multiple_priority = {Priority = {"High", "Medium"}},
        
        -- Case insensitive filters
        case_insensitive = {
            Status = {
                {value = "completed", case_insensitive = true}
            }
        },
        
        -- Operator filters
        exact_match = {
            Status = {
                {value = "Completed", operator = "="}
            }
        },
        contains = {
            Status = {
                {value = "Complete", operator = "~"}
            }
        },
        starts_with = {
            Status = {
                {value = "Comp", operator = "^"}
            }
        },
        ends_with = {
            Status = {
                {value = "ted", operator = "$"}
            }
        },
        
        -- Exclusion filters
        exclusion = {
            ["!Status"] = {"Completed", "Closed"}
        },
        exclusion_single = {
            ["!Status"] = "Completed"
        },
        
        -- Mixed filters
        mixed_inclusion_exclusion = {
            Priority = "High",
            ["!Status"] = "Completed"
        },
        
        -- Complex filters
        complex = {
            Status = {
                {value = "Completed", operator = "="},
                {value = "In Progress", operator = "="}
            },
            Priority = {
                {value = "High", operator = "="}
            },
            ["!Tags"] = "Draft"
        }
    }
end

-- Helper function to assert task list contains expected files
function M.assert_task_list_contains(task_list, expected_files)
    for _, expected_file in ipairs(expected_files) do
        assert.is_true(
            vim.tbl_contains(task_list, expected_file),
            "Task list should contain " .. expected_file
        )
    end
end

-- Helper function to assert task list does not contain unexpected files
function M.assert_task_list_excludes(task_list, unexpected_files)
    for _, unexpected_file in ipairs(unexpected_files) do
        assert.is_false(
            vim.tbl_contains(task_list, unexpected_file),
            "Task list should not contain " .. unexpected_file
        )
    end
end

-- Helper function to assert task list has exact count
function M.assert_task_list_count(task_list, expected_count)
    assert.equals(
        expected_count,
        #task_list,
        "Task list should have exactly " .. expected_count .. " items, got " .. #task_list
    )
end

-- Helper function to create mock telescope module
function M.create_mock_telescope()
    local captured_task_list = nil
    local call_count = 0
    
    return {
        taskFinder = function(task_list)
            captured_task_list = task_list
            call_count = call_count + 1
        end,
        get_captured_task_list = function()
            return captured_task_list
        end,
        get_call_count = function()
            return call_count
        end,
        reset = function()
            captured_task_list = nil
            call_count = 0
        end
    }
end

-- Helper function to create mock task module
function M.create_mock_task()
    local captured_params = nil
    local call_count = 0
    
    return {
        getTaskList = function(path)
            call_count = call_count + 1
            return {path .. "/task1.md", path .. "/task2.md"}
        end,
        filterTasks = function(task_list, filters)
            call_count = call_count + 1
            captured_params = {task_list = task_list, filters = filters}
            return task_list -- Return unfiltered for testing
        end,
        getTaskProperties = function(path)
            call_count = call_count + 1
            return {Status = "Completed", Priority = "High"}
        end,
        get_captured_params = function()
            return captured_params
        end,
        get_call_count = function()
            return call_count
        end,
        reset = function()
            captured_params = nil
            call_count = 0
        end
    }
end

-- Helper function to setup mocks for testing
function M.setup_mocks(mocks)
    local original_modules = {}
    
    for module_name, mock_module in pairs(mocks) do
        original_modules[module_name] = package.loaded[module_name]
        package.loaded[module_name] = mock_module
    end
    
    return {
        restore = function()
            for module_name, original_module in pairs(original_modules) do
                package.loaded[module_name] = original_module
            end
        end
    }
end

-- Helper function to reload a module (useful after mocking)
function M.reload_module(module_name)
    package.loaded[module_name] = nil
    return require(module_name)
end

return M