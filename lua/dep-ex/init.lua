local dep_ex = {}

-- Default configuration
local config = {
  workspace = "/path/to/your/workspace",
  repo_owner = "default_owner"
}

-- Set up configuration
function dep_ex.setup(user_config)
  config = vim.tbl_extend("force", config, user_config)
end

-- Find all mix.exs files in the project excluding deps directory
local function find_mix_files()
  return vim.fn.systemlist("find . -path ./deps -prune -o -name 'mix.exs' -print")
end

-- Utility to replace dependency in mix.exs
local function replace_dependency_in_file(file_path, lib_name, new_line)
  local lines = {}
  local file = io.open(file_path, "r")
  if not file then
    print("Error opening file: " .. file_path)
    return
  end

  -- Read all lines and modify target dependency line
  for line in file:lines() do
    if line:match("{:" .. lib_name .. ",") and new_line ~= nil then
      table.insert(lines, "# " .. line) -- Comment out the original line
      table.insert(lines, new_line)      -- Add new dependency line
    elseif new_line == nil and line:match("#") and line:match("{:" .. lib_name) then
      print("Aqui dentro")
      local uncommented_line = line:gsub("^%s*#", "")
      print(uncommented_line)
      table.insert(lines, uncommented_line)
    elseif new_line == nil and line:match("{:" .. lib_name .. ", path:") then
      -- Not adding to the table will remove it
    else
      table.insert(lines, line)
    end
  end
  file:close()

  -- Write modified lines back to mix.exs
  file = io.open(file_path, "w")
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()
end

-- Run shell commands
local function run_shell_command(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return result
end

-- Commands to switch dependency

-- Local path command
function dep_ex.local_dependency(lib_name)
  local path = config.workspace .. "/" .. lib_name
  local new_line = string.format("{:%s, path: \"%s\"},", lib_name, path)

  -- Update all mix.exs files
  local mix_files = find_mix_files()
  for _, file_path in ipairs(mix_files) do
    replace_dependency_in_file(file_path, lib_name, new_line)
  end

  -- Run mix format and mix deps.get
  run_shell_command("mix format")
  run_shell_command("mix deps.get")
  print("Switched " .. lib_name .. " to local path: " .. path)
end

-- Remote branch command
function dep_ex.branch_dependency(lib_name, branch_name, owner)
  owner = owner or config.repo_owner
  local repo_url = string.format("https://github.com/%s/%s.git", owner, lib_name)
  local new_line = string.format("{:%s, git: \"%s\", branch: \"%s\"},", lib_name, repo_url, branch_name)

  -- Update all mix.exs files
  local mix_files = find_mix_files()
  for _, file_path in ipairs(mix_files) do
    replace_dependency_in_file(file_path, lib_name, new_line)
  end

  -- Run mix format and mix deps.get
  run_shell_command("mix format")
  run_shell_command("mix deps.get")
  print("Switched " .. lib_name .. " to branch: " .. branch_name .. " at " .. repo_url)
end

-- Original version command
function dep_ex.origin_dependency(lib_name)
  -- Update all mix.exs files
  local mix_files = find_mix_files()
  for _, file_path in ipairs(mix_files) do
    replace_dependency_in_file(file_path, lib_name, nil)
  end

  -- Run mix format and mix deps.get
  run_shell_command("mix format")
  run_shell_command("mix deps.get")
  print("Switched " .. lib_name .. " back to origin")
end

-- Register commands in Neovim
vim.api.nvim_create_user_command("DepExLocal", function(opts)
  dep_ex.local_dependency(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DepExBranch", function(opts)
  local args = vim.split(opts.args, " ")
  local lib_name = args[1]
  local branch_name = args[2]
  local owner = args[3] or config.repo_owner
  dep_ex.branch_dependency(lib_name, branch_name, owner)
end, { nargs = "+" })

vim.api.nvim_create_user_command("DepExOrigin", function(opts)
  dep_ex.origin_dependency(opts.args)
end, { nargs = 1 })

return dep_ex
