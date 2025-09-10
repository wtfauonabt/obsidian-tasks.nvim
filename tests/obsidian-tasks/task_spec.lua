local task = require("obsidian-tasks.task")

describe("task module", function()
    local test_dir = "/tmp/obsidian-tasks-test"
    local test_files = {}

    -- Setup: Create test directory and files
    before_each(function()
        -- Create test directory
        vim.fn.mkdir(test_dir, "p")
        
        -- Create test files with different property formats
        test_files = {
            simple = test_dir .. "/simple.md",
            bracket_list = test_dir .. "/bracket_list.md",
            bullet_list = test_dir .. "/bullet_list.md",
            mixed_properties = test_dir .. "/mixed_properties.md",
            case_variations = test_dir .. "/case_variations.md"
        }
        
        -- Simple property format
        local simple_content = [[
---
Status: Completed
Priority: High
---

# Simple Task
This is a simple task with basic properties.
]]
        vim.fn.writefile(vim.split(simple_content, "\n"), test_files.simple)
        
        -- Bracket list format
        local bracket_content = [=[
---
Status: [[Closed]]
Tags: [[Important]], [[Urgent]]
---

# Bracket List Task
This task uses bracket list format.
]=]
        vim.fn.writefile(vim.split(bracket_content, "\n"), test_files.bracket_list)
        
        -- Bullet list format
        local bullet_content = [[
---
Status:
  - Not Started
  - In Progress
Tags:
  - Development
  - Testing
---

# Bullet List Task
This task uses bullet list format.
]]
        vim.fn.writefile(vim.split(bullet_content, "\n"), test_files.bullet_list)
        
        -- Mixed properties
        local mixed_content = [=[
---
Status: Completed
Priority: [[High]]
Tags:
  - Important
  - Done
Assignee: John Doe
---

# Mixed Properties Task
This task has mixed property formats.
]=]
        vim.fn.writefile(vim.split(mixed_content, "\n"), test_files.mixed_properties)
        
        -- Case variations
        local case_content = [=[
---
Status: completed
Priority: HIGH
Tags: [[Important]], [[URGENT]]
---

# Case Variations Task
This task has different case variations.
]=]
        vim.fn.writefile(vim.split(case_content, "\n"), test_files.case_variations)
    end)

    -- Cleanup: Remove test directory
    after_each(function()
        vim.fn.delete(test_dir, "rf")
    end)

    describe("getTaskProperties", function()
        it("should parse simple properties", function()
            local properties = task.getTaskProperties(test_files.simple)

            assert.equals("Completed", properties.Status)
            assert.equals("High", properties.Priority)
        end)

        it("should parse bracket list properties", function()
            local properties = task.getTaskProperties(test_files.bracket_list)

            assert.equals("Closed", properties.Status)
            assert.equals("Important, Urgent", properties.Tags)
        end)

        it("should parse bullet list properties", function()
            local properties = task.getTaskProperties(test_files.bullet_list)

            assert.equals("Not Started, In Progress", properties.Status)
            assert.equals("Development, Testing", properties.Tags)
        end)

        it("should parse mixed property formats", function()
            local properties = task.getTaskProperties(test_files.mixed_properties)

            assert.equals("Completed", properties.Status)
            assert.equals("High", properties.Priority)
            assert.equals("Important, Done", properties.Tags)
            assert.equals("John Doe", properties.Assignee)
        end)

        it("should handle non-existent files", function()
            local properties = task.getTaskProperties("/non/existent/file.md")

            assert.is_not_nil(properties)
            assert.is_nil(properties.Status)
            assert.is_nil(properties.Priority)
        end)

        it("should handle empty files", function()
            local empty_file = test_dir .. "/empty.md"
            vim.fn.writefile({}, empty_file)

            local properties = task.getTaskProperties(empty_file)

            assert.is_not_nil(properties)
            assert.is_nil(properties.Status)
        end)
    end)

    describe("getTaskList", function()
        it("should return list of task files", function()
            local task_list = task.getTaskList(test_dir)

            assert.equals(5, #task_list)
            assert.is_true(vim.tbl_contains(task_list, test_files.simple))
            assert.is_true(vim.tbl_contains(task_list, test_files.bracket_list))
            assert.is_true(vim.tbl_contains(task_list, test_files.bullet_list))
        end)

        it("should handle empty directory", function()
            local empty_dir = test_dir .. "/empty"
            vim.fn.mkdir(empty_dir, "p")

            local task_list = task.getTaskList(empty_dir)

            assert.equals(0, #task_list)
        end)
    end)

    describe("filterTasks", function()
        local task_list

        before_each(function()
            task_list = task.getTaskList(test_dir)
        end)

        it("should filter by single value", function()
            local filters = {Status = "Completed"}
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should filter by multiple values", function()
            local filters = {Status = {"Completed", "Closed"}}
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(3, #filtered)  -- simple, bracket_list, mixed_properties
        end)

        it("should filter by multiple properties", function()
            local filters = {
                Status = "Completed",
                Priority = "High"
            }
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should handle case sensitive filtering", function()
            local filters = {Status = "completed"}  -- lowercase
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(1, #filtered)  -- only case_variations
        end)

        it("should handle case insensitive filtering with metadata", function()
            local filters = {
                Status = {
                    {value = "completed", case_insensitive = true}
                }
            }
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(3, #filtered)  -- simple, mixed_properties, case_variations
        end)

        it("should handle mixed case sensitivity", function()
            local filters = {
                Status = {
                    {value = "completed", case_insensitive = true},
                    {value = "Closed", case_insensitive = false}
                }
            }
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(4, #filtered)  -- simple, bracket_list, mixed_properties, case_variations
        end)

        it("should handle mixed filter formats", function()
            local filters = {
                Status = {
                    "Completed",  -- case sensitive
                    {value = "completed", case_insensitive = true}  -- case insensitive
                }
            }
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(3, #filtered)  -- simple, mixed_properties, case_variations
        end)

        it("should filter by list properties", function()
            local filters = {Tags = "Important"}
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(3, #filtered)  -- bracket_list, mixed_properties, case_variations
        end)

        it("should handle non-matching filters", function()
            local filters = {Status = "NonExistent"}
            local filtered = task.filterTasks(task_list, filters)

            assert.equals(0, #filtered)
        end)

        it("should handle empty filters", function()
            local filtered = task.filterTasks(task_list, {})

            assert.equals(5, #filtered)  -- all tasks
        end)

        it("should handle invalid file paths", function()
            local invalid_list = {"", nil, "/non/existent/file.md"}
            local filtered = task.filterTasks(invalid_list, {Status = "Completed"})

            assert.equals(0, #filtered)
        end)
    end)

    describe("edge cases", function()
        it("should handle properties without values", function()
            local no_value_file = test_dir .. "/no_value.md"
            local content = [[
---
Status:
Priority: High
---

# No Value Task
]]
            vim.fn.writefile(vim.split(content, "\n"), no_value_file)

            local properties = task.getTaskProperties(no_value_file)

            assert.is_not_nil(properties)
            assert.equals("High", properties.Priority)
            assert.is_nil(properties.Status)
        end)

        it("should handle malformed properties", function()
            local malformed_file = test_dir .. "/malformed.md"
            local content = [[
---
Status: Completed: Extra
Priority: High
---

# Malformed Task
]]
            vim.fn.writefile(vim.split(content, "\n"), malformed_file)

            local properties = task.getTaskProperties(malformed_file)

            assert.is_not_nil(properties)
            assert.equals("Completed: Extra", properties.Status)
            assert.equals("High", properties.Priority)
        end)

        it("should handle very long property values", function()
            local long_file = test_dir .. "/long.md"
            local long_value = string.rep("Very long value ", 100)
            local content = string.format([[
---
Status: %s
---

# Long Value Task
]], long_value)
            vim.fn.writefile(vim.split(content, "\n"), long_file)

            local properties = task.getTaskProperties(long_file)

            assert.is_not_nil(properties)
            assert.equals(long_value, properties.Status)
        end)
    end)

    describe("logical operators", function()
        local task_list

        before_each(function()
            task_list = task.getTaskList(test_dir)
        end)

        it("should support exact match operator (=)", function()
            local filters = {
                Status = {
                    {value = "Completed", operator = "="}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should support not equal operator (!=)", function()
            local filters = {
                Status = {
                    {value = "Completed", operator = "!="}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(3, #filtered)  -- bracket_list, bullet_list, case_variations
        end)

        it("should support contains operator (~)", function()
            local filters = {
                Status = {
                    {value = "Complete", operator = "~"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should support does not contain operator (!~)", function()
            local filters = {
                Status = {
                    {value = "Complete", operator = "!~"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(3, #filtered)  -- bracket_list, bullet_list, case_variations
        end)

        it("should support starts with operator (^)", function()
            local filters = {
                Status = {
                    {value = "Comp", operator = "^"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should support does not start with operator (!^)", function()
            local filters = {
                Status = {
                    {value = "Comp", operator = "!^"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(3, #filtered)  -- bracket_list, bullet_list, case_variations
        end)

        it("should support ends with operator ($)", function()
            local filters = {
                Status = {
                    {value = "ted", operator = "$"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(4, #filtered)  -- simple, mixed_properties, case_variations, bullet_list (In Progress)
        end)

        it("should support does not end with operator (!$)", function()
            local filters = {
                Status = {
                    {value = "ted", operator = "!$"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(2, #filtered)  -- bracket_list, bullet_list
        end)

        it("should support mixed operators", function()
            local filters = {
                Status = {
                    {value = "Completed", operator = "="},
                    {value = "Closed", operator = "!="}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(4, #filtered)  -- all files
        end)

        it("should support operators with case insensitive", function()
            local filters = {
                Status = {
                    {value = "completed", operator = "=", case_insensitive = true}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(3, #filtered)  -- simple, mixed_properties, case_variations
        end)

        it("should default to contains operator (~) for simple values", function()
            local filters = {
                Status = "Complete"  -- Should use ~ operator by default
            }
            local filtered = task.filterTasks(task_list, filters)
            
            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)

        it("should handle unknown operators gracefully", function()
            local filters = {
                Status = {
                    {value = "Complete", operator = "unknown"}
                }
            }
            local filtered = task.filterTasks(task_list, filters)
            
            -- Should default to contains behavior
            assert.equals(2, #filtered)  -- simple and mixed_properties
        end)
    end)
end)
