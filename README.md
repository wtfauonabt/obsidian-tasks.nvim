# obsidian-tasks.nvim

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ellisonleao/nvim-plugin-template/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A powerful Neovim plugin for filtering and managing Obsidian tasks with advanced metadata support, logical operators, and flexible property parsing.

## Features

- **Advanced Task Filtering** - Filter tasks using powerful logical operators
- **Flexible Property Parsing** - Supports multiple Obsidian property formats
- **Case Insensitive Filtering** - Per-filter case sensitivity control
- **Logical Operators** - 8 different operators for precise filtering
- **Comprehensive Testing** - 34+ test cases ensuring reliability
- **Telescope Integration** - Seamless integration with Telescope picker

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "your-username/obsidian-tasks.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("obsidian-tasks").setup({
      -- Your configuration here
    })
  end,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "your-username/obsidian-tasks.nvim",
  requires = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("obsidian-tasks").setup()
  end,
}
```

## Supported Property Formats

The plugin supports various Obsidian property formats:

### Simple Properties
```yaml
---
Status: Completed
Priority: High
---
```

### Bracket List Format
```yaml
---
Status: [[Closed]]
Tags: [[Important]], [[Urgent]]
---
```

### Multi-line Bullet Lists
```yaml
---
Status:
  - Not Started
  - In Progress
Tags:
  - Development
  - Testing
---
```

### Mixed Formats
```yaml
---
Status: Completed
Priority: [[High]]
Tags:
  - Important
  - Done
Assignee: John Doe
---
```

## Filtering System

### Basic Filtering

```lua
local task = require("obsidian-tasks.task")

-- Simple single value filtering
local filters = {Status = "Completed"}
local filtered_tasks = task.filterTasks(task_list, filters)

-- Multiple values
local filters = {Status = {"Completed", "Closed"}}
local filtered_tasks = task.filterTasks(task_list, filters)
```

### Logical Operators

The plugin supports 8 powerful logical operators:

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Exact match | `{value = "Completed", operator = "="}` |
| `!=` | Not equal | `{value = "Draft", operator = "!="}` |
| `~` | Contains (default) | `{value = "Complete", operator = "~"}` |
| `!~` | Does not contain | `{value = "Draft", operator = "!~"}` |
| `^` | Starts with | `{value = "In", operator = "^"}` |
| `!^` | Does not start with | `{value = "Not", operator = "!^"}` |
| `$` | Ends with | `{value = "ed", operator = "$"}` |
| `!$` | Does not end with | `{value = "ing", operator = "!$"}` |

### Advanced Filtering Examples

```lua
-- Exact match with case insensitive
local filters = {
  Status = {
    {value = "completed", operator = "=", case_insensitive = true}
  }
}

-- Multiple operators
local filters = {
  Status = {
    {value = "Completed", operator = "="},
    {value = "Closed", operator = "!="}
  }
}

-- Starts with and ends with
local filters = {
  Status = {
    {value = "In", operator = "^"},
    {value = "ed", operator = "$"}
  }
}

-- Mixed format (backward compatible)
local filters = {
  Status = {
    "Completed",  -- defaults to ~ operator
    {value = "Closed", operator = "=", case_insensitive = true}
  }
}
```

### Real-World Use Cases

```lua
-- Find all completed tasks
local completed_tasks = task.filterTasks(task_list, {
  Status = {{value = "Completed", operator = "="}}
})

-- Find tasks that are not drafts
local active_tasks = task.filterTasks(task_list, {
  Status = {{value = "Draft", operator = "!~"}}
})

-- Find tasks in progress (case insensitive)
local in_progress = task.filterTasks(task_list, {
  Status = {{value = "progress", operator = "~", case_insensitive = true}}
})

-- Find tasks ending with "ed" (completed, started, etc.)
local finished_tasks = task.filterTasks(task_list, {
  Status = {{value = "ed", operator = "$"}}
})

-- Complex filtering: High priority tasks that are not completed
local urgent_tasks = task.filterTasks(task_list, {
  Priority = {{value = "High", operator = "="}},
  Status = {{value = "Completed", operator = "!="}}
})
```

## API Reference

### `getTaskProperties(task_path)`

Parses Obsidian task properties from a markdown file.

**Parameters:**
- `task_path` (string): Path to the markdown file

**Returns:**
- `table`: Parsed properties

**Example:**
```lua
local properties = task.getTaskProperties("/path/to/task.md")
-- Returns: {Status = "Completed", Priority = "High", Tags = "Important, Urgent"}
```

### `getTaskList(path)`

Gets a list of task files from a directory.

**Parameters:**
- `path` (string): Directory path

**Returns:**
- `table`: List of file paths

**Example:**
```lua
local task_files = task.getTaskList("/path/to/tasks")
-- Returns: {"/path/to/tasks/task1.md", "/path/to/tasks/task2.md"}
```

### `filterTasks(task_list, filters)`

Filters a list of tasks based on criteria.

**Parameters:**
- `task_list` (table): List of task file paths
- `filters` (table): Filter criteria

**Returns:**
- `table`: Filtered list of task file paths

**Filter Format:**
```lua
{
  PropertyName = {
    "simple_value",  -- Uses ~ operator by default
    {value = "value", operator = "=", case_insensitive = false}
  }
}
```

## Configuration

```lua
require("obsidian-tasks").setup({
  -- Configuration options here
})
```

## Testing

The plugin includes comprehensive tests covering all functionality:

```bash
# Run all tests
make test

# Run specific test file
nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedFile tests/obsidian-tasks/task_spec.lua" -c "quit"
```

Test coverage includes:
- Property parsing for all supported formats
- All logical operators
- Case sensitivity handling
- Edge cases and error handling
- Backward compatibility

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing
- Integrates with [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Inspired by Obsidian's powerful task management capabilities