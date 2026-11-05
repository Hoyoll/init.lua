-- Bootstrap lazy.nvim

vim.g.clipboard = {
	name = "win32yank",
	copy = {
		["+"] = "win32yank.exe -i --crlf",
		["*"] = "win32yank.exe -i --crlf",
	},
	paste = {
		["+"] = "win32yank.exe -o --lf",
		["*"] = "win32yank.exe -o --lf",
	},
	cache_enabled = 1,
}

vim.opt.clipboard = "unnamedplus"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true -- show current line number
vim.opt.relativenumber = true -- show relative numbers
vim.opt.foldenable = false
vim.opt.splitbelow = true
--vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.o.statusline = "~%f %m"
-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"nvim-treesitter/nvim-treesitter",
			lazy = false,
			highlight = {
				enable = true,
			},
			build = ":TSUpdate",
			event = { "BufReadPost", "BufNewFile" },
		},
		{
			"Hoyoll/neovim-ayu",
			priority = 1000, -- load early for colors
			config = function()
				require("ayu").setup({
					mirage = false,
				})
				vim.cmd.colorscheme("ayu")
			end,
		},
		{
			"X3eRo0/dired.nvim",
			dependencies = {
				{ "MunifTanjim/nui.nvim" },
			},
			lazy = false,
			config = function()
				require("dired").setup({
					path_separator = "/", -- Use '/' as the path separator
					show_hidden = true, -- Show hidden files
					show_icons = true, -- Show icons (patched font required)
					show_banner = true, -- Do not show the banner
					hide_details = false, -- Show file details by default
					sort_order = "name", -- Sort files by name by default
					override_cwd = true, -- Override cwd by default

					keybinds = {
						dired_enter = "<CR>",
						dired_back = "-",
						dired_up = "_",
						dired_rename = "R",
						dired_quit = "q",
					},
					colors = {
						DiredDimText = { link = {}, bg = "NONE", fg = "505050", gui = "NONE" },
						DiredDirectoryName = { link = {}, bg = "NONE", fg = "9370DB", gui = "NONE" },
						DiredMoveFile = { link = {}, bg = "NONE", fg = "ff3399", gui = "bold" },
					},
				})
			end,
		},
		{
			"ej-shafran/compile-mode.nvim",
			version = "^5.0.0",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "m00qek/baleia.nvim", tag = "v1.3.0" },
			},
			config = function()
				---@type CompileModeOpts
				vim.g.compile_mode = {
					baleia_setup = true,
					default_command = "",
					use_circular_error_navigation = false,
					focus_compilation_buffer = true,
					input_word_completion = true,
				}
			end,
		},
		{
			"nvim-telescope/telescope-ui-select.nvim",
			dependencies = {
				"nvim-telescope/telescope.nvim",
			},
		},
		{
			"nvim-telescope/telescope.nvim",
			version = "*",
			cmd = "Telescope",
			config = function()
				require("telescope").setup({
					defaults = {
						layout_config = {
							width = 0.9,
							height = 0.8,
							--preview_width = 0.55,	
						},
					},
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown({
								previewer = false,
								width = 0.8,
								height = 0.6,
							}),
						},
					},
				})
			end,
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
				{ "nvim-tree/nvim-web-devicons" },
			},
		},
		{
			"NeogitOrg/neogit",
			lazy = true,
			dependencies = {
				"esmuellert/codediff.nvim", -- optional
				"m00qek/baleia.nvim",
				"nvim-telescope/telescope.nvim", -- optional
			},
			cmd = "Neogit",
			keys = {
				{ "<leader>ng", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
			},
		},
		{
			"Saghen/blink.cmp",
			version = "*",
			dependencies = {
				"neovim/nvim-lspconfig",
			},
			opts = {
				keymap = {
					preset = "default",
					["<CR>"] = { "select_and_accept", "fallback" },
				},

				appearance = {
					use_nvim_cmp_as_default = false,
					nerd_font_variant = "mono",
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				cmdline = {
					sources = { "cmdline" },
				},
				completion = {
					documentation = {
						auto_show = false,
					},
				},
			},
			opts_extend = { "sources.default" },
			config = function(_, opts)
				require("blink.cmp").setup(opts)
				vim.lsp.config("*", {
					capabilities = require("blink.cmp").get_lsp_capabilities(),
				})
				vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "NONE", ctermbg = "NONE" })
				--vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', ctermbg = 'NONE', fg = '#56b6c2' })
			end,
		},
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = { "Saghen/blink.cmp" },
		},
		{
			"diogo464/hotreload.nvim",
			opts = {
				silent = true,
			}, -- Uses fs_event watchers by default
		},
		{
			"mason-org/mason-lspconfig.nvim",
			event = { "BufReadPre", "BufNewFile" },
			opts = {
				ensure_installed = { "lua_ls", "ts_ls", "zig_ls" },
			},
			dependencies = {
				{
					"mason-org/mason.nvim",
					opts = {},
				},
				"neovim/nvim-lspconfig",
			},
			config = function()
				vim.lsp.config["rust_analyzer"] = {
					cmd = { "rust-analyzer" },
					filetypes = { "rust" },
					root_markers = { "Cargo.toml", "rust-project.json" },
					settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
							},
						},
					},
				}
				vim.lsp.config["css_lsp"] = {
					cmd = { "vscode-css-language-server", "--stdio" },
					filetypes = { "css" },
					root_markers = { "style.css" },
					single_file_support = true
				}
				vim.lsp.config["odin_ls"] = {
					cmd = { "ols" },
					filetypes = { "odin" },
					root_markers = { "ols.json", ".git" },
					single_file_support = true,
				}
				vim.lsp.config["c_ls"] = {
					cmd = { "clangd" },
					filetypes = { "c", "cpp", "c++", "h", "hpp" },
					root_markers = { ".git" },
					single_file_support = true,
				}
				vim.lsp.config["ts_ls"] = {
					cmd = { "typescript-language-server", "--stdio" },
					filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
					root_markers = { "package.json", "tsconfig.json", ".git" },
					init_options = {
						hostInfo = "neovim",
					},
				}
				vim.lsp.config["gd_ls"] = {
					cmd = { "ncat", "localhost", "6008" },
					filetypes = { "gdscript" },
					root_markers = { "project.godot" },
					init_options = {
						hostInfo = "neovim",
					},
				}
				vim.lsp.config["zig_ls"] = {
					cmd = { "zls" },
					file_types = { "zig", "zir" },
					root_markers = { "build.zig" },
					single_file_support = true,
				}
				vim.lsp.config["harper_ls"] = {
					cmd = { "harper-ls", "--stdio" },
					--root_markers = { ".git" },
					filetypes = { "markdown", "text", "tex", "typst", "html" },
					single_file_support = true,
				}
				vim.lsp.config["c3_ls"] = {
					cmd = { "c3lsp" },
					filetypes = { "c3" },
					root_markers = { "project.json" },
					single_file_support = true,
					init_options = {
						hostInfo = "neovim",
					},
				}
				vim.lsp.config["ma_ls"] = {
					cmd = { "ma" },
					filetypes = { "markdown", "diff" },
					--root_markers = { ".git"},
					single_file_support = true
				}
				vim.lsp.config["dev_ma_ls"] = {
					cmd = { "ma", "--dev" },
					filetypes = { "markdown", "diff" },
					single_file_support = true,
				}
				--vim.lsp.config[] = {}
			end,
		},
	},
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
})
--vim.lsp.set_log_level("trace")
vim.lsp.inlay_hint.enable(true)
--vim.o.foldmethod = "manual"
--vim.o.foldenable = true
--vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", "popup" }
vim.opt.autocomplete = false

vim.api.nvim_create_user_command("Hp", function()
	vim.lsp.enable("harper_ls")
	vim.opt.wrap = true
	vim.opt.foldenable = false
end, {})

vim.api.nvim_create_user_command("Ts", function()
	vim.lsp.enable("ts_ls")
end, {})

vim.api.nvim_create_user_command("Css", function()
	vim.lsp.enable("css_lsp")
end, {})



vim.api.nvim_create_user_command("Ma", function()
	vim.lsp.enable("ma_ls")
end, {})

vim.api.nvim_create_user_command("MaDev", function()
	vim.lsp.enable("dev_ma_ls")
end, {})

vim.api.nvim_create_user_command("MaKill", function()
	vim.lsp.disable("ma_ls")
end, {})

vim.api.nvim_create_user_command("Odin", function()
	vim.lsp.enable("odin_ls")
end, {})

vim.api.nvim_create_user_command("C", function()
	vim.lsp.enable("c_ls")
end, {})

vim.api.nvim_create_user_command("Godot", function()
	vim.lsp.enable("gd_ls")
end, {})

vim.api.nvim_create_user_command("C3", function()
	vim.lsp.enable("c3_ls")
end, {})

vim.api.nvim_create_user_command("Rust", function()
	vim.lsp.enable("rust_analyzer")
end, {})

vim.api.nvim_create_user_command("Lua", function()
	vim.lsp.enable("lua_ls")
end, {})

vim.api.nvim_create_user_command("Zig", function()
	vim.lsp.enable("zig_ls")
end, {})

vim.api.nvim_set_hl(0, "LineNr", { fg = "#495162" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#5a6378", bold = true })

vim.opt.fillchars = { eob = " " }

local function remap()
	vim.keymap.set({ "n", "v" }, "<C-c>", '"+y')
	vim.keymap.set("n", "<C-v>", '"+p')
	vim.keymap.set("i", "<C-v>", "<C-r>+")

	vim.keymap.set("n", "<C-s>", function()
		vim.cmd(":w!")
	end)
	vim.keymap.set("i", "<C-s>", function()
		vim.cmd(":w!")
	end)
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	vim.keymap.set("n", "<C-z>", function()
		vim.cmd(":undo")
	end)

	vim.keymap.set("i", "<C-z>", function()
		vim.cmd(":undo")
	end)

	vim.keymap.set("n", "<C-y>", function()
		vim.cmd(":redo")
	end)

	vim.keymap.set("i", "<C-y>", function()
		vim.cmd(":redo")
	end)

	vim.keymap.set("n", "<C-e>", function()
		vim.cmd(":Telescope find_files")
	end)

	vim.keymap.set("i", "<C-e>", function()
		vim.cmd(":Telescope find_files")
	end)

	vim.keymap.set({ "i", "n" }, "<C-d>", function()
		vim.cmd(":Telescope diagnostics")
	end)

	vim.keymap.set({ "i", "n" }, "<C-w>", function()
		vim.cmd(":Telescope grep_string")
	end)

	vim.keymap.set({ "i", "n" }, "<C-r>", function()
		vim.cmd(":Telescope live_grep")
	end)

	vim.keymap.set("n", "<C-\\>", function()
		vim.cmd(":Telescope buffers")
	end)

	vim.keymap.set("i", "<C-\\>", function()
		vim.cmd(":Telescope buffers")
	end)

	vim.keymap.set("i", "<C-x>", function()
		vim.cmd(":Compile")
	end)

	vim.keymap.set("n", "<C-x>", function()
		vim.cmd(":Compile")
	end)

	vim.keymap.set("n", "q", function()
		vim.cmd(":bd")
	end)
	vim.keymap.set("n", "<Tab>", function()
		vim.cmd(":Dired")
	end)
end

vim.api.nvim_create_user_command("Remap", remap, {})

vim.api.nvim_create_user_command("Zon", function()
	vim.cmd(":hi Normal guibg=NONE")
	vim.cmd(":hi StatusLine guibg=NONE")
	vim.cmd(":hi SignColumn guibg=NONE")
	vim.cmd(":hi NormalFloat guibg=NONE")
	vim.cmd(":hi FloatBorder guibg=NONE")
	vim.cmd(":highlight Pmenu guibg=NONE ctermbg=NONE")
	--vim.cmd(":hi TelescopeSelection guibg=NONE")
	vim.api.nvim_set_hl(0, "TelescopeSelection", {
		bg = "NONE",
	})
end, {})

vim.api.nvim_create_user_command("Todo", function()
	vim.cmd(":Compile rg 'TO-DO' --vimgrep .")
end, {})

vim.api.nvim_create_user_command("Zen", function()
	vim.cmd(":hi Normal guibg=#10141c")
end, {})

vim.keymap.set("n", "n", function()
	vim.lsp.buf.definition()
end)

vim.keymap.set("n", "b", function()
	vim.lsp.buf.hover()
end)

vim.keymap.set("n", ",", function()
	--require("telescope.builtin").lsp_code_actions()
	vim.lsp.buf.code_action()
end)

vim.keymap.set("n", "m", function()
	vim.diagnostic.open_float(nil, {
		focusable = true,
	})
end)

vim.keymap.set("n", "<C-q>", function()
	vim.cmd(":q")
end)

--vim.keymap.set("n", ":", function()
--	vim.cmd(":Pulse")
--end)
local function init()
	vim.cmd(":Zon")
	require("telescope").load_extension("ui-select")

	if vim.fn.argc() == 0 then
		vim.cmd("Dired")
	end
	remap()
end

init()
