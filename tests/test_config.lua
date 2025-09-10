-- Test configuration for obsidian-tasks.nvim

local M = {}

-- Test configuration that can be used across all tests
M.test_config = {
    vault_path = "/tmp/obsidian-tasks-test-vault",
    task_folder = "/tasks",
    filters = {
        ["!Status"] = {"Completed", "Closed"}
    }
}

-- Alternative test configurations for different scenarios
M.configs = {
    -- Configuration for testing inclusion filters
    inclusion_only = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Status = {"Completed", "In Progress"},
            Priority = "High"
        }
    },
    
    -- Configuration for testing exclusion filters
    exclusion_only = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            ["!Status"] = {"Completed", "Closed", "Draft"}
        }
    },
    
    -- Configuration for testing mixed filters
    mixed_filters = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Priority = "High",
            ["!Status"] = {"Completed", "Closed"}
        }
    },
    
    -- Configuration for testing case sensitivity
    case_sensitive = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Status = {
                {value = "Completed", case_insensitive = false}
            }
        }
    },
    
    -- Configuration for testing case insensitive
    case_insensitive = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Status = {
                {value = "completed", case_insensitive = true}
            }
        }
    },
    
    -- Configuration for testing operators
    operators = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Status = {
                {value = "Complete", operator = "~"},
                {value = "Closed", operator = "="}
            }
        }
    },
    
    -- Configuration for testing complex scenarios
    complex = {
        vault_path = "/tmp/obsidian-tasks-test-vault",
        task_folder = "/tasks",
        filters = {
            Status = {
                {value = "Completed", operator = "="},
                {value = "In Progress", operator = "="}
            },
            Priority = {
                {value = "High", operator = "="}
            },
            ["!Tags"] = {
                {value = "Draft", operator = "~"}
            }
        }
    }
}

-- Test data paths
M.test_paths = {
    vault_root = "/tmp/obsidian-tasks-test-vault",
    task_folder = "/tmp/obsidian-tasks-test-vault/tasks",
    temp_dir = "/tmp/obsidian-tasks-temp",
    sample_data = "/tmp/obsidian-tasks-sample-data"
}

-- Sample task content templates
M.task_templates = {
    simple = [[
---
Status: %s
Priority: %s
---

# %s Task
This is a %s task.
]],
    
    bracket = [[
---
Status: [[%s]]
Priority: [[%s]]
---

# %s Task
This task uses bracket format.
]],
    
    bullet = [[
---
Status:
  - %s
Priority: %s
---

# %s Task
This task uses bullet format.
]],
    
    mixed = [[
---
Status: %s
Priority: [[%s]]
Tags:
  - %s
---

# %s Task
This task has mixed formats.
]],
    
    complex = [[
---
Status: %s
Priority: %s
Tags:
  - %s
  - %s
Assignee: %s
Due: %s
Created: %s
Updated: %s
---

# %s Task
This is a complex task with many properties.
]]
}

-- Helper function to get test configuration by name
function M.get_config(config_name)
    return M.configs[config_name] or M.test_config
end

-- Helper function to get test path by name
function M.get_path(path_name)
    return M.test_paths[path_name] or M.test_paths.temp_dir
end

-- Helper function to get task template by name
function M.get_template(template_name)
    return M.task_templates[template_name] or M.task_templates.simple
end

-- Helper function to create task content from template
function M.create_task_content(template_name, ...)
    local template = M.get_template(template_name)
    return string.format(template, ...)
end

return M