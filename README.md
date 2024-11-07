# dep-ex.nvim

`dep-ex.nvim` is a Neovim plugin designed for Elixir developers who frequently switch dependencies between different configurations. It streamlines updating dependency paths in `mix.exs` files, allowing you to quickly toggle between local paths, remote branches, or the original source.

With `dep-ex.nvim`, switching dependencies becomes as simple as running a Neovim command.

## Features

- Automatically edit multiple `mix.exs` files to point a dependency to a local directory, remote branch, or original origin.
- Supports switching back to original configuration.
- Integrates with Elixir's `mix format` and `mix deps.get` to keep dependencies up to date.

## Installation

To install `dep-ex.nvim` using **lazy.nvim**, add the following to your configuration:

```lua
require("lazy").setup({
  {
    "vicentedpsantos/dep-ex",
    config = function()
      require("dep-ex").setup({
        workspace = "/Path/to/your/workspace",
        repo_owner = "default_owner"
      })
    end
  }
})
```

## Configuration

`dep-ex.nvim` offers a simple setup function that you can customize to match your development environment:

- `workspace`: Absolute path to your development workspace where dependencies are located.
- `repo_owner`: Default owner for repositories when specifying remote branches.

Example configuration:

```lua
require("dep-ex").setup({
  workspace = "/Path/to/your/workspace",
  repo_owner = "owner"
})
```

This configuration will be used by default when commands are executed.

## Usage

`dep-ex.nvim` provides three main commands for managing dependencies:

### 1. `:DepExLocal <lib_name>`

Switch a dependency to a **local path**. For example:

```vim
:DepExLocal kase
```

If `workspace` is set to `"/Users/youruser/work"`, this command will edit all `mix.exs` files to replace the dependency for `kase` with:

```elixir
{:kase, path: "/Users/youruser/work/kase"}
```

### 2. `:DepExBranch <lib_name> <branch_name> [repo_owner]`

Point a dependency to a **specific branch** in a remote Git repository. You can optionally specify a custom owner.

Example:

```vim
:DepExBranch kase feature-branch vicentedpsantos
```

If `repo_owner` isn’t specified, it defaults to the configured `repo_owner`. This command will change the dependency for `kase` to:

```elixir
{:kase, git: "https://github.com/vicentedpsantos/kase.git", branch: "feature-branch"}
```

### 3. `:DepExOrigin <lib_name>`

Restore the dependency to its **original configuration**. For example:

```vim
:DepExOrigin kase
```

This will remove any local or branch-specific configurations and revert to the initial dependency declaration for `kase`.

## How It Works

The plugin finds and edits all `mix.exs` files in the current directory (excluding the `./deps` directory) and performs the following:
- Comments out any existing configuration for the specified dependency.
- Adds a new configuration line (local path or branch).
- Runs `mix format` and `mix deps.get` to format and update dependencies.

## Known Bugs
- Hardcoded comma after dependency: Currently, the comma after a dependency is being hardcoded. This could cause issues with formatting, especially when switching between dependency configurations.
- Branch dependency line breaks: If you point to a branch dependency and after saving it, the line breaks in the mix.exs file, this can cause issues when switching back to the original configuration. It may fail or mess up the formatting.

## Contributing

Contributions are welcome! To contribute:

1. **Fork the repository.**
2. **Create a new branch** for your feature or bug fix:
   ```sh
   git checkout -b feature/your-feature
   ```
3. **Make your changes** and commit them with descriptive messages.
4. **Push to your fork** and open a pull request:
   ```sh
   git push origin feature/your-feature
   ```

Before submitting a pull request, please ensure all features and changes are documented and tested.

## License

`dep-ex.nvim` is open-source software licensed under the MIT License.
