local files = require("obsidian-tasks.files")

describe("files module", function()
    local test_dir = "/tmp/obsidian-tasks-files-test"
    
    before_each(function()
        -- Create test directory
        vim.fn.mkdir(test_dir, "p")
        
        -- Create test files
        vim.fn.writefile({"content1"}, test_dir .. "/file1.md")
        vim.fn.writefile({"content2"}, test_dir .. "/file2.md")
        vim.fn.writefile({"content3"}, test_dir .. "/file3.md")
        
        -- Create subdirectory
        vim.fn.mkdir(test_dir .. "/subdir", "p")
        vim.fn.writefile({"content4"}, test_dir .. "/subdir/file4.md")
    end)
    
    after_each(function()
        vim.fn.delete(test_dir, "rf")
    end)
    
    describe("ls", function()
        it("should list files in directory", function()
            local file_list = files.ls(test_dir)
            
            -- Should include all files and directories
            assert.is_true(vim.tbl_contains(file_list, "file1.md"))
            assert.is_true(vim.tbl_contains(file_list, "file2.md"))
            assert.is_true(vim.tbl_contains(file_list, "file3.md"))
            assert.is_true(vim.tbl_contains(file_list, "subdir"))
        end)
        
        it("should handle empty directory", function()
            local empty_dir = test_dir .. "/empty"
            vim.fn.mkdir(empty_dir, "p")
            
            local file_list = files.ls(empty_dir)
            
            assert.equals(0, #file_list)
        end)
        
        it("should handle non-existent directory", function()
            local non_existent_dir = "/non/existent/directory"
            
            -- This should not crash, but may return empty list or error
            local success, result = pcall(files.ls, non_existent_dir)
            
            -- Either it succeeds with empty list or fails gracefully
            if success then
                assert.is_table(result)
            else
                -- Error is acceptable for non-existent directory
                assert.is_string(result)
            end
        end)
        
        it("should handle directory with special characters", function()
            local special_dir = test_dir .. "/special-chars"
            vim.fn.mkdir(special_dir, "p")
            vim.fn.writefile({"content"}, special_dir .. "/file-with-special-chars.md")
            
            local file_list = files.ls(special_dir)
            
            assert.equals(1, #file_list)
            assert.equals("file-with-special-chars.md", file_list[1])
        end)
        
        it("should handle directory with hidden files", function()
            local hidden_dir = test_dir .. "/hidden"
            vim.fn.mkdir(hidden_dir, "p")
            vim.fn.writefile({"content"}, hidden_dir .. "/.hidden-file.md")
            vim.fn.writefile({"content"}, hidden_dir .. "/visible-file.md")
            
            local file_list = files.ls(hidden_dir)
            
            -- Should include both hidden and visible files
            assert.is_true(vim.tbl_contains(file_list, ".hidden-file.md"))
            assert.is_true(vim.tbl_contains(file_list, "visible-file.md"))
        end)
        
        it("should handle directory with mixed file types", function()
            local mixed_dir = test_dir .. "/mixed"
            vim.fn.mkdir(mixed_dir, "p")
            vim.fn.writefile({"content"}, mixed_dir .. "/file.md")
            vim.fn.writefile({"content"}, mixed_dir .. "/file.txt")
            vim.fn.writefile({"content"}, mixed_dir .. "/file.json")
            vim.fn.mkdir(mixed_dir .. "/subdir", "p")
            
            local file_list = files.ls(mixed_dir)
            
            assert.equals(4, #file_list)
            assert.is_true(vim.tbl_contains(file_list, "file.md"))
            assert.is_true(vim.tbl_contains(file_list, "file.txt"))
            assert.is_true(vim.tbl_contains(file_list, "file.json"))
            assert.is_true(vim.tbl_contains(file_list, "subdir"))
        end)
    end)
end)