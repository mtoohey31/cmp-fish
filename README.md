# `completion-fish`

[Fish shell](https://fishshell.com) completion source for [completion-nvim](https://github.com/nvim-lua/completion-nvim).

## Usage

```lua
require'completion'.addCompletionSource('fish', require'completion-fish'.complete_item)
```

Additionally, make sure the fish completion item is enabled for the fish filetype, for example:

```vim
let g:completion_chain_complete_list = {
                  \ 'default': [{ 'complete_items': ['lsp',  'path']}],
                  \ 'fish': [{ 'complete_items': ['fish', 'lsp', 'path']}]
                  \ }
```
