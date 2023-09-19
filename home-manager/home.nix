# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
# You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "slinde";
    homeDirectory = "/home/slinde";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Browser
    firefox

    # Utils
    ripgrep
    fd
    fzf
    gh

    # Misc
    neofetch
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Sebastian Hempel Linde";
    userEmail = "sebastian@tved-linde.dk";
  };


  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    extraLuaConfig = ''
      local g = vim.g        -- Global variables
      local opt = vim.opt    -- Set options
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      -----------------------------------------------------------
      -- General
      -----------------------------------------------------------
      opt.mouse = 'a'                       -- Enable mouse support
      opt.clipboard = 'unnamedplus'         -- Copy/paste to system clipboard
      opt.swapfile = false                  -- Don't use swapfile
      opt.completeopt = 'menuone,noinsert,noselect'  -- Autocomplete options

      -----------------------------------------------------------
      -- Neovim UI
      -----------------------------------------------------------
      opt.number = true           -- Show line number
      opt.showmatch = true        -- Highlight matching parenthesis
      opt.foldmethod = 'marker'   -- Enable folding (default 'foldmarker')
      opt.colorcolumn = '80'      -- Line lenght marker at 80 columns
      opt.splitright = true       -- Vertical split to the right
      opt.splitbelow = true       -- Horizontal split to the bottom
      opt.ignorecase = true       -- Ignore case letters when search
      opt.smartcase = true        -- Ignore lowercase for the whole pattern
      opt.linebreak = true        -- Wrap on word boundary
      opt.laststatus=3            -- Set global statusline
      
      -----------------------------------------------------------
      -- Tabs, indent
      -----------------------------------------------------------
      opt.expandtab = true        -- Use spaces instead of tabs
      opt.shiftwidth = 4          -- Shift 4 spaces when tab
      opt.tabstop = 4             -- 1 tab == 4 spaces
      opt.smartindent = true      -- Autoindent new lines
      
      -----------------------------------------------------------
      -- Memory, CPU
      -----------------------------------------------------------
      opt.hidden = true           -- Enable background buffers
      opt.history = 100           -- Remember N lines in history
      opt.lazyredraw = true       -- Faster scrolling
      opt.synmaxcol = 240         -- Max column for syntax highlight
      opt.updatetime = 250        -- ms to wait for trigger an event
      
      -----------------------------------------------------------
      -- Startup
      -----------------------------------------------------------
      -- Disable nvim intro
      opt.shortmess:append "sI"
      
      -- -- Disable builtin plugins
      local disabled_built_ins = {
         "2html_plugin",
         "getscript",
         "getscriptPlugin",
         "gzip",
         "logipat",
         "matchit",
         "tar",
         "tarPlugin",
         "rrhelper",
         "spellfile_plugin",
         "vimball",
         "vimballPlugin",
         "zip",
         "zipPlugin",
         "tutor",
         "rplugin",
         "synmenu",
         "optwin",
         "compiler",
         "bugreport",
         "ftplugin",
      }
      
      for _, plugin in pairs(disabled_built_ins) do
         g["loaded_" .. plugin] = 1
      end

      augroup('setIndent', { clear = true })
      autocmd('Filetype', {
        group = 'setIndent',
        pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript',
          'yaml', 'lua'
        },
        command = 'setlocal shiftwidth=2 tabstop=2'
      })
    '';

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      mason-nvim
      mason-lspconfig-nvim
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      {
          plugin = lsp-zero-nvim;
          type = "lua";
          config = ''
          local lsp = require('lsp-zero').preset({})

          lsp.on_attach(function(client, bufnr)
            -- see :help lsp-zero-keybindings
            -- to learn the available actions
            lsp.default_keymaps({buffer = bufnr})
          end)
      
          lsp.setup()
          '';
      }
      {
          plugin = tokyonight-nvim;
          type = "lua";
          config = ''
          vim.cmd("colorscheme tokyonight-night")
          '';
      }
      mini-nvim
    ];
    extraPackages = with pkgs; [
      cargo
    ];
  };

  # Nicely reload system units when changing configs
  # system.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
