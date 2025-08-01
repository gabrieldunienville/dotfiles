return {
  'MeanderingProgrammer/markdown.nvim',
  main = 'render-markdown',
  name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  config = function()
    require('render-markdown').setup {
      heading = {
        icons = { '', '', '', '', '', '' }, -- No icons for headings
        position = 'inline',
        width = 'block',
        -- left_margin = 1,
        left_pad = 1,
        right_pad = 2,
        min_width = 20,
        backgrounds = {
          'RenderMarkdownH1Bg',
          'RenderMarkdownH2Bg',
          'RenderMarkdownH3Bg',
          '',
          'RenderMarkdownH5Bg',
          'RenderMarkdownH6Bg',
        },
        foregrounds = {
          'RenderMarkdownH1',
          'RenderMarkdownH2',
          'RenderMarkdownH3',
          'RenderMarkdownH4',
          'RenderMarkdownH5',
          'RenderMarkdownH6',
        },
      },
      indent = {
        enabled = true,
        -- skip_heading = true,
        skip_level = 2,
        per_level = 1,
        icon = '',
      },
      code = {
        width = 'block',
        min_width = 60,
        left_pad = 2,
        right_pad = 4,
        language_pad = 2,
      },
      pipe_table = {
        style = 'normal',
      },
    }
  end,
}
