# remote-edit.nvim

Edit remote files via SSH with fzf-lua integration.

## Requirements

- Neovim >= 0.10
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- SSH configured in `~/.ssh/config`

## Installation

### lazy.nvim

```lua
return {
  "ultimatile/remote-edit.nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  opts = {},
}
```

## Usage

```vim
:Redit           " Select host from ~/.ssh/config
:Redit hostname  " Connect to specified host directly
```

Select a host from your SSH config, then browse and edit files.

### Keymaps (in fzf picker)

| Key | Action |
|-----|--------|
| `<C-h>` (default) | Show/hide dotfiles |

Dotfiles are hidden by default. Press `<C-h>` in the fzf picker to toggle visibility.

## Configuration

```lua
opts = {
  keymaps = {
    toggle_hidden = "<C-h>",  -- change dotfile toggle key
  },
}
```

## License

Apache-2.0

## Acknowledgments

Project structure based on [nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template).
