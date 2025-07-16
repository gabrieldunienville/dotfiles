return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = true,
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
      indent = {
        char = '┊',
        -- char = '▏', -- left aligned
        -- char = '▊',  -- thick
        -- char = '▕',  -- right aligned
        -- char = '┇',  -- dashed
      },
    },
  },
}
