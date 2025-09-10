describe("obsidian-tasks main module", function()
    local obsidian_tasks
    
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
        package.loaded["obsidian-tasks"] = nil
        obsidian_tasks = require("obsidian-tasks")
    end)
    
    describe("setup", function()
        it("should merge configuration with defaults", function()
            local custom_config = {
                vault_path = "/custom/vault/path",
                task_folder = "/custom/tasks",
                filters = {
                    Status = "In Progress"
                }
            }
            
            obsidian_tasks.setup(custom_config)
            
            -- Verify configuration was merged
            assert.equals("/custom/vault/path", obsidian_tasks.config.vault_path)
            assert.equals("/custom/tasks", obsidian_tasks.config.task_folder)
            assert.equals("In Progress", obsidian_tasks.config.filters.Status)
        end)
        
        it("should use default configuration when no args provided", function()
            obsidian_tasks.setup()
            
            -- Verify default configuration
            assert.is_not_nil(obsidian_tasks.config)
            assert.is_not_nil(obsidian_tasks.config.vault_path)
            assert.is_not_nil(obsidian_tasks.config.task_folder)
            assert.is_not_nil(obsidian_tasks.config.filters)
        end)
        
        it("should handle nil configuration", function()
            obsidian_tasks.setup(nil)
            
            -- Should not crash and use defaults
            assert.is_not_nil(obsidian_tasks.config)
        end)
        
        it("should preserve existing configuration when merging", function()
            -- Set initial configuration
            obsidian_tasks.setup({
                vault_path = "/initial/vault",
                filters = {
                    Priority = "High"
                }
            })
            
            -- Merge with new configuration
            obsidian_tasks.setup({
                task_folder = "/new/tasks"
            })
            
            -- Should preserve existing and add new
            assert.equals("/initial/vault", obsidian_tasks.config.vault_path)
            assert.equals("/new/tasks", obsidian_tasks.config.task_folder)
            assert.equals("High", obsidian_tasks.config.filters.Priority)
        end)
        
        it("should handle deep merging of nested tables", function()
            obsidian_tasks.setup({
                filters = {
                    Status = "Completed",
                    Priority = "High"
                }
            })
            
            obsidian_tasks.setup({
                filters = {
                    Status = "In Progress"
                }
            })
            
            -- Should merge filters properly
            assert.equals("In Progress", obsidian_tasks.config.filters.Status)
            assert.equals("High", obsidian_tasks.config.filters.Priority)
        end)
    end)
    
    describe("search", function()
        it("should call search function without crashing", function()
            -- Setup configuration
            obsidian_tasks.setup({
                vault_path = "/test/vault",
                task_folder = "/test/tasks",
                filters = {Status = "Completed"}
            })
            
            -- Call search (should not crash)
            obsidian_tasks.search()
        end)
        
        it("should handle search with default configuration", function()
            -- Reset configuration
            obsidian_tasks.setup({})
            
            -- Call search (should not crash)
            obsidian_tasks.search()
        end)
    end)
    
    describe("configuration validation", function()
        it("should handle invalid vault_path", function()
            obsidian_tasks.setup({
                vault_path = nil
            })
            
            -- Should not crash
            assert.is_not_nil(obsidian_tasks.config)
        end)
        
        it("should handle invalid task_folder", function()
            obsidian_tasks.setup({
                task_folder = nil
            })
            
            -- Should not crash
            assert.is_not_nil(obsidian_tasks.config)
        end)
        
        it("should handle invalid filters", function()
            obsidian_tasks.setup({
                filters = "invalid"
            })
            
            -- Should not crash
            assert.is_not_nil(obsidian_tasks.config)
        end)
        
        it("should handle empty configuration table", function()
            obsidian_tasks.setup({})
            
            -- Should use defaults
            assert.is_not_nil(obsidian_tasks.config)
            assert.is_not_nil(obsidian_tasks.config.vault_path)
            assert.is_not_nil(obsidian_tasks.config.task_folder)
            assert.is_not_nil(obsidian_tasks.config.filters)
        end)
    end)
    
    describe("exclusion filters in configuration", function()
        it("should support exclusion filters in default config", function()
            -- The default config should have exclusion filters
            obsidian_tasks.setup({})
            
            assert.is_not_nil(obsidian_tasks.config.filters)
            assert.is_not_nil(obsidian_tasks.config.filters["!Status"])
            assert.is_table(obsidian_tasks.config.filters["!Status"])
            assert.is_true(vim.tbl_contains(obsidian_tasks.config.filters["!Status"], "Completed"))
            assert.is_true(vim.tbl_contains(obsidian_tasks.config.filters["!Status"], "Closed"))
        end)
        
        it("should allow overriding exclusion filters", function()
            obsidian_tasks.setup({
                filters = {
                    ["!Status"] = {"Draft", "Archived"}
                }
            })
            
            assert.equals("Draft", obsidian_tasks.config.filters["!Status"][1])
            assert.equals("Archived", obsidian_tasks.config.filters["!Status"][2])
        end)
        
        it("should allow mixing inclusion and exclusion filters", function()
            obsidian_tasks.setup({
                filters = {
                    Priority = "High",
                    ["!Status"] = {"Completed", "Closed"}
                }
            })
            
            assert.equals("High", obsidian_tasks.config.filters.Priority)
            assert.is_not_nil(obsidian_tasks.config.filters["!Status"])
            assert.equals("Completed", obsidian_tasks.config.filters["!Status"][1])
            assert.equals("Closed", obsidian_tasks.config.filters["!Status"][2])
        end)
    end)
end)