<!-- cSpell:ignore nvim -->

# `cmp-fish`

[Fish shell](https://fishshell.com) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

## Usage

```lua
require("packer").use({ "mtoohey31/cmp-fish", ft = "fish" })

cmp.setup({
  sources = cmp.config.sources({
    { name = 'fish' }
  })
})
```

## Configuration

You can provide a custom Fish path using options:

```lua
cmp.setup({
  sources = cmp.config.sources({
    { name = 'fish', option = { fish_path = "/usr/bin/fish" } }
  })
})
```
