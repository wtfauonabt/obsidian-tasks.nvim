describe("module", function()
    local module
    local test_dir = "/tmp/obsidian-tasks-module-test"
    local test_files = {}
    
    before_each(function()
        -- Mock telescope components
        local mock_picker = {
            find = function() end
        }
        
        local mock_finder = {
            new_table = function(opts)
                return {}
            end
        }
        
        local mock_pickers = {
            new = function(opts, config)
                return mock_picker
            end
        }
        
        local mock_config = {
            values = {
                generic_sorter = function() return {} end
            }
        }
        
        local mock_previewers = {
            cat = {
                new = function() return {} end
            }
        }
        
        -- Mock the telescope modules
        package.loaded["telescope.pickers"] = mock_pickers
        package.loaded["telescope.finders"] = mock_finder
        package.loaded["telescope.config"] = mock_config
        package.loaded["telescope.previewers"] = mock_previewers
        
        -- Reload modules to use mocked dependencies
        package.loaded["obsidian-tasks.telescope"] = nil
        package.loaded["obsidian-tasks.module"] = nil
        module = require("obsidian-tasks.module")
        
        -- Create test directory
        vim.fn.mkdir(test_dir, "p")
        
        -- Create test files
        test_files = {
            completed = test_dir .. "/completed.md",
            in_progress = test_dir .. "/in_progress.md",
            not_started = test_dir .. "/not_started.md"
        }
        
        -- Completed task
        local completed_content = [[
---
Status: Completed
Priority: High
---

# Completed Task
This task is completed.
]]
        vim.fn.writefile(vim.split(completed_content, "\n"), test_files.completed)
        
        -- In progress task
        local in_progress_content = [[
---
Status: In Progress
Priority: Medium
---

# In Progress Task
This task is in progress.
]]
        vim.fn.writefile(vim.split(in_progress_content, "\n"), test_files.in_progress)
        
        -- Not started task
        local not_started_content = [[
---
Status: Not Started
Priority: Low
---

# Not Started Task
This task has not been started.
]]
        vim.fn.writefile(vim.split(not_started_content, "\n"), test_files.not_started)
    end)
    
    after_each(function()
        vim.fn.delete(test_dir, "rf")
    end)
    
    describe("search", function()
        it("should search tasks with filters", function()
            local vault_path = test_dir
            local task_folder = ""
            local filters = {Status = "Completed"}
            
            -- Test the function (should not crash)
            module.search(vault_path, task_folder, filters)
        end)
        
        it("should search tasks with exclusion filters", function()
            local vault_path = test_dir
            local task_folder = ""
            local filters = {["!Status"] = {"Completed", "Closed"}}
            
            -- Test the function (should not crash)
            module.search(vault_path, task_folder, filters)
        end)
        
        it("should search tasks with multiple filters", function()
            local vault_path = test_dir
            local task_folder = ""
            local filters = {
                Status = {"Completed", "In Progress"},
                Priority = "High"
            }
            
            -- Test the function (should not crash)
            module.search(vault_path, task_folder, filters)
        end)
        
        it("should handle empty filters", function()
            local vault_path = test_dir
            local task_folder = ""
            local filters = {}
            
            -- Test the function (should not crash)
            module.search(vault_path, task_folder, filters)
        end)
        
        it("should handle non-existent vault path", function()
            local vault_path = "/non/existent/path"
            local task_folder = ""
            local filters = {Status = "Completed"}
            
            -- Test the function (should not crash)
            module.search(vault_path, task_folder, filters)
        end)
        
        it("should handle nil parameters", function()
            -- Test with nil parameters (should not crash)
            module.search(nil, nil, nil)
        end)
    end)
end)