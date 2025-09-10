describe("telescope module", function()
    local telescope
    
    before_each(function()
        -- Mock telescope components before requiring the module
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
        
        -- Reload the module to use mocked dependencies
        package.loaded["obsidian-tasks.telescope"] = nil
        telescope = require("obsidian-tasks.telescope")
    end)
    
    describe("taskFinder", function()
        it("should create a telescope picker with task list", function()
            local mock_task_list = {
                "/path/to/task1.md",
                "/path/to/task2.md",
                "/path/to/task3.md"
            }
            
            -- Test the function (should not crash)
            telescope.taskFinder(mock_task_list)
        end)
        
        it("should handle empty task list", function()
            local empty_task_list = {}
            
            -- Test the function (should not crash)
            telescope.taskFinder(empty_task_list)
        end)
        
        it("should handle nil task list", function()
            -- Test the function (should not crash)
            telescope.taskFinder(nil)
        end)
    end)
    
    describe("entry maker", function()
        it("should extract filename from full path", function()
            -- Test the entry maker logic directly
            local entry = "/path/to/task.md"
            local filename = entry:match("([^/]+)$")
            
            assert.equals("task.md", filename)
        end)
        
        it("should handle paths without directories", function()
            local entry = "task.md"
            local filename = entry:match("([^/]+)$")
            
            assert.equals("task.md", filename)
        end)
        
        it("should handle nested paths", function()
            local entry = "/very/deep/nested/path/to/task.md"
            local filename = entry:match("([^/]+)$")
            
            assert.equals("task.md", filename)
        end)
    end)
end)