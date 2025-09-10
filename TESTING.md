# Testing Guide for obsidian-tasks.nvim

This document provides comprehensive information about testing the obsidian-tasks.nvim plugin using plenary.nvim and busted.

## Overview

The plugin uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) with [busted](https://olivinelabs.com/busted/) for testing. This provides a robust testing framework with BDD-style syntax, mocking capabilities, and comprehensive assertion functions.

## Test Structure

```
tests/
├── minimal_init.lua              # Test initialization and setup
├── test_helpers.lua             # Helper utilities for tests
├── test_config.lua              # Test configuration and data
└── obsidian-tasks/
    ├── task_spec.lua            # Tests for task.lua module
    ├── telescope_spec.lua       # Tests for telescope.lua module
    ├── files_spec.lua           # Tests for files.lua module
    ├── module_spec.lua          # Tests for module.lua
    └── obsidian-tasks_spec.lua  # Tests for main obsidian-tasks.lua
```

## Running Tests

### Using Make

```bash
# Run all tests
make test

# Run tests with verbose output
make test-verbose

# Run tests with coverage report
make test-coverage

# Run specific test file
make test-file FILE=task_spec

# Show help
make test-help
```

### Using the Test Script

```bash
# Run all tests
lua scripts/test.lua

# Run tests matching a pattern
lua scripts/test.lua task

# Run with verbose output
lua scripts/test.lua -v

# Run with coverage
lua scripts/test.lua -c

# Show help
lua scripts/test.lua -h
```

### Direct Neovim Commands

```bash
# Run all tests
nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/" -c "quit"

# Run specific test file
nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedFile tests/obsidian-tasks/task_spec.lua" -c "quit"
```

## Test Coverage

The test suite covers:

### Core Functionality
- ✅ Property parsing (simple, bracket list, bullet list formats)
- ✅ Task filtering with various operators
- ✅ Case sensitivity handling
- ✅ Exclusion filters (`!Status`)
- ✅ Mixed inclusion/exclusion filters
- ✅ Edge cases and error handling

### Modules Tested
- ✅ `task.lua` - Core task processing and filtering
- ✅ `telescope.lua` - Telescope integration
- ✅ `files.lua` - File system operations
- ✅ `module.lua` - Main module coordination
- ✅ `obsidian-tasks.lua` - Main plugin interface

### Test Categories

#### 1. Property Parsing Tests
- Simple properties (`Status: Completed`)
- Bracket list format (`Status: [[Closed]]`)
- Bullet list format (`Status:\n  - Not Started`)
- Mixed formats
- Edge cases (empty values, malformed properties)

#### 2. Filtering Tests
- Single value filters
- Multiple value filters
- Case sensitive/insensitive filtering
- All logical operators (`=`, `!=`, `~`, `!~`, `^`, `!^`, `$`, `!$`)
- Exclusion filters (`!Status`)
- Mixed inclusion/exclusion filters

#### 3. Integration Tests
- End-to-end search functionality
- Telescope integration
- Configuration handling
- Error handling

## Writing Tests

### Basic Test Structure

```lua
local module = require("obsidian-tasks.module")

describe("module name", function()
    local test_dir = "/tmp/test"
    
    before_each(function()
        -- Setup test data
        vim.fn.mkdir(test_dir, "p")
    end)
    
    after_each(function()
        -- Cleanup
        vim.fn.delete(test_dir, "rf")
    end)
    
    describe("function name", function()
        it("should do something", function()
            -- Test implementation
            assert.equals(expected, actual)
        end)
    end)
end)
```

### Using Test Helpers

```lua
local helpers = require("test_helpers")

describe("using helpers", function()
    local test_dir = "/tmp/test"
    
    before_each(function()
        helpers.create_test_dir(test_dir)
        helpers.create_test_file(test_dir .. "/task.md", "content")
    end)
    
    after_each(function()
        helpers.cleanup_test_path(test_dir)
    end)
    
    it("should use helpers", function()
        local tasks = helpers.create_sample_tasks(test_dir)
        helpers.assert_task_list_contains(task_list, {tasks.simple})
    end)
end)
```

### Mocking Dependencies

```lua
local helpers = require("test_helpers")

describe("with mocks", function()
    it("should mock telescope", function()
        local mock_telescope = helpers.create_mock_telescope()
        local mocks = helpers.setup_mocks({
            ["obsidian-tasks.telescope"] = mock_telescope
        })
        
        -- Test with mocked telescope
        telescope.taskFinder({"task1.md", "task2.md"})
        
        assert.equals(2, #mock_telescope.get_captured_task_list())
        
        mocks.restore()
    end)
end)
```

## Test Data

### Sample Task Files

The test suite creates various sample task files with different property formats:

- **Simple format**: Basic key-value properties
- **Bracket format**: Obsidian bracket list syntax
- **Bullet format**: Multi-line bullet lists
- **Mixed format**: Combination of different formats
- **Case variations**: Different capitalization
- **Complex format**: Multiple properties and formats

### Sample Filters

Pre-defined filter configurations for testing:

- Simple filters (single values)
- Multiple value filters
- Case sensitive/insensitive filters
- Operator-based filters
- Exclusion filters
- Mixed inclusion/exclusion filters
- Complex multi-criteria filters

## Assertions

The test suite uses busted's assertion functions:

- `assert.equals(expected, actual)` - Equality
- `assert.is_true(value)` - Truthiness
- `assert.is_false(value)` - Falsiness
- `assert.is_nil(value)` - Nil check
- `assert.is_not_nil(value)` - Not nil check
- `assert.is_table(value)` - Type check
- `assert.is_string(value)` - Type check
- `assert.is_function(value)` - Type check

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Use `before_each` and `after_each` for setup/cleanup
- Create temporary directories for file operations

### 2. Descriptive Test Names
```lua
it("should exclude tasks with Completed status using !Status filter", function()
    -- Test implementation
end)
```

### 3. Test Edge Cases
- Empty inputs
- Invalid inputs
- Non-existent files
- Malformed data

### 4. Use Helpers
- Leverage test helpers for common operations
- Create reusable test data
- Use mocks for external dependencies

### 5. Comprehensive Coverage
- Test all code paths
- Test both success and failure cases
- Test with various input combinations

## Debugging Tests

### Verbose Output
```bash
make test-verbose
```

### Run Single Test
```bash
make test-file FILE=task_spec
```

### Debug Specific Test
Add debug prints in test files:
```lua
it("should debug test", function()
    print("Debug: task_list =", vim.inspect(task_list))
    -- Test implementation
end)
```

## Continuous Integration

The test suite is designed to run in CI environments:

- Headless Neovim execution
- No interactive prompts
- Clean exit codes
- Comprehensive error reporting

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Add tests for edge cases
4. Update test documentation
5. Run full test suite before submitting

## Troubleshooting

### Common Issues

1. **Tests fail with file not found**
   - Ensure test files are created in `before_each`
   - Check file paths are correct

2. **Mocking not working**
   - Ensure modules are reloaded after mocking
   - Check mock setup and teardown

3. **Tests are flaky**
   - Ensure proper cleanup in `after_each`
   - Check for race conditions

4. **Coverage not working**
   - Ensure plenary.nvim is properly installed
   - Check busted configuration

### Getting Help

- Check the test output for specific error messages
- Use verbose mode for detailed output
- Review existing tests for examples
- Check plenary.nvim documentation