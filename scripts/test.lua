#!/usr/bin/env lua

-- Test runner script for obsidian-tasks.nvim
-- Usage: lua scripts/test.lua [options]

local argparse = require("plenary.argparse")

-- Parse command line arguments
local parser = argparse()
parser:argument("test_pattern", "Test pattern to run (optional)")
parser:flag("-v", "--verbose", "Verbose output")
parser:flag("-c", "--coverage", "Generate coverage report")
parser:flag("-h", "--help", "Show help")

local args = parser:parse()

if args.help then
    print("obsidian-tasks.nvim Test Runner")
    print("")
    print("Usage: lua scripts/test.lua [options] [test_pattern]")
    print("")
    print("Options:")
    print("  -v, --verbose     Verbose output")
    print("  -c, --coverage   Generate coverage report")
    print("  -h, --help        Show this help")
    print("")
    print("Examples:")
    print("  lua scripts/test.lua                    # Run all tests")
    print("  lua scripts/test.lua task                # Run tests matching 'task'")
    print("  lua scripts/test.lua -v                  # Run all tests with verbose output")
    print("  lua scripts/test.lua -c task_spec        # Run task_spec with coverage")
    os.exit(0)
end

-- Set up test environment
local test_init = "tests/minimal_init.lua"
local test_dir = "tests/"

-- Build test command
local cmd_parts = {
    "nvim",
    "--headless",
    "--noplugin",
    "-u", test_init
}

-- Add coverage if requested
if args.coverage then
    table.insert(cmd_parts, "-c")
    table.insert(cmd_parts, "lua require('plenary.busted').run({coverage = true})")
end

-- Add test pattern if provided
if args.test_pattern then
    table.insert(cmd_parts, "-c")
    table.insert(cmd_parts, string.format("PlenaryBustedFile tests/obsidian-tasks/%s_spec.lua", args.test_pattern))
else
    table.insert(cmd_parts, "-c")
    table.insert(cmd_parts, string.format("PlenaryBustedDirectory %s { minimal_init = '%s' }", test_dir, test_init))
end

table.insert(cmd_parts, "-c")
table.insert(cmd_parts, "quit")

-- Add verbose flag if requested
if args.verbose then
    table.insert(cmd_parts, "-c")
    table.insert(cmd_parts, "lua require('plenary.busted').run({verbose = true})")
end

-- Execute test command
local cmd = table.concat(cmd_parts, " ")
print("Running: " .. cmd)
print("")

local exit_code = os.execute(cmd)

if exit_code == 0 then
    print("")
    print("✅ All tests passed!")
else
    print("")
    print("❌ Tests failed!")
    os.exit(1)
end