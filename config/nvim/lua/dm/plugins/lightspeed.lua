-- For now, I am using this plugin only as a replacement for `clever-f`. Maybe
-- in the future, if I like the `s`/`S` behavior, I might enable it, but most
-- likely remap it to a different key like `<leader>j`/`<leader>k`.

return {
  {
    'ggandor/lightspeed.nvim',
    keys = {
      { 'f', '<Plug>Lightspeed_f', mode = { 'n', 'x', 'o' } },
      { 'F', '<Plug>Lightspeed_F', mode = { 'n', 'x', 'o' } },
      { 't', '<Plug>Lightspeed_t', mode = { 'n', 'x', 'o' } },
      { 'T', '<Plug>Lightspeed_T', mode = { 'n', 'x', 'o' } },
    },
    init = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
    opts = {
      limit_ft_matches = 10,
      exit_after_idle_msecs = {
        unlabeled = 2000,
      },
    },
  },
}
