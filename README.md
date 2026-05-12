# todos.nvim

A simple Neovim filetype plugin for `.todo` files with checkbox toggling and syntax highlighting.

## Features

- **Automatic filetype detection** for `.todo` files
- **Checkbox toggling** with a single keypress
  - Toggle between `- [ ]` (unchecked) and `- [x]` (checked)
- **Syntax highlighting** with visual differentiation:
  - Unchecked items appear in default text color
  - Checked items appear dimmed with strikethrough
  - Indentation (4 spaces) is highlighted as comments

## 📦 Installation

Install the plugin with your preferred package manager:

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
  "rrossmiller/todos.nvim",
  config = function()
    require("todos").setup()
  end
}
```

## 🚀 Usage

1. Create or open a file with the `.todo` extension
2. Write your todo items using markdown checkbox syntax:
   ```
   - [ ] Unchecked task
   - [x] Completed task
   ```
3. Press `tt` in normal mode to toggle the checkbox on the current line

## ⚙️ Configuration

The plugin works out of the box with no configuration needed. Just call `setup()`:

```lua
require("todos").setup()
```

### Default Keybindings

When a `.todo` file is opened:
- `tt` (normal mode) - Toggle checkbox between `[ ]` and `[x]`
- `tT` (normal mode) - Toggle the current line and all nested items (sub todos)
- `<leader>ta` (normal mode) - Add a new todo item to the current line


