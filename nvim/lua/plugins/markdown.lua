return {
  'MeanderingProgrammer/markdown.nvim',
  main = 'render-markdown',
  name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  opts = {
    pipe_table = {
      style = 'normal',
    },
  },
}
