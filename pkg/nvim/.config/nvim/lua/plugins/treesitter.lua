return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    main = 'nvim-treesitter.config',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'elixir',
        'eex',
        'erlang',
        'go',
        'heex',
        'html',
        'javascript',
        -- 'lua' omitted: Neovim bundles a matched lua parser+queries pair;
        -- letting nvim-treesitter manage it installs a mismatched older parser.
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'ruby',
        'tsx',
        'vim',
        'vimdoc',
      },
      auto_install = true,
    },
    config = function(_, opts)
      require('nvim-treesitter.config').setup(opts)

      -- On the `main` branch `ensure_installed` in opts is ignored;
      -- parsers must be installed explicitly (async, no-op if present).
      require('nvim-treesitter').install(opts.ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
