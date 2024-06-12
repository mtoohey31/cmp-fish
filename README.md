<!-- cSpell:ignore nvim -->

# `cmp-fish`

[Fish shell](https://fishshell.com) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

## Usage

```lua
require("packer").use({ "mtoohey31/cmp-fish", ft = "fish" })

require("cmp_fish").setup()
cmp.setup({
  sources = cmp.config.sources({
    { name = 'fish' }
  })
})
```

## Configuration

The default configuration looks like this:

```lua
{
    fish_path = "fish"
}
```

You can override the default configuration through `setup`:

```lua
require("cmp_fish").setup({
    fish_path = "/usr/bin/fish"
})
```
