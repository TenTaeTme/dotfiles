-- Автокоманда для LSP биндов и локальных настроек буфера
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- omnifunc для автодополнения через LSP
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		local opts = { buffer = ev.buf }

		-- Переходы по символам и справка
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>Telescope lsp_document_symbols<cr>", opts)

		-- Подпись функции
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

		-- Workspace utils
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)

		-- Тип, рефы, диагностика
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

		-- Плавающее окно с диагностикой по текущей строке
		vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

		-- Git blame под курсором
		vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", opts)

		-- Диагностика через Telescope
		vim.keymap.set("n", "<leader>ld", function()
			require("telescope.builtin").diagnostics({ bufnr = 0 })
		end, opts)

		vim.keymap.set("n", "<leader>lw", function()
			require("telescope.builtin").diagnostics({})
		end, opts)

		-- Code actions для фиксов
		vim.keymap.set("n", "<leader>cf", function()
			vim.lsp.buf.code_action()
		end, opts)
		vim.keymap.set("v", "<leader>cf", function()
			vim.lsp.buf.range_code_action()
		end, opts)
	end,
})

-- Расширенные возможности клиента LSP (completion, semantic tokens и так далее)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem = {
	documentationFormat = { "markdown", "plaintext" },
	snippetSupport = true,
	preselectSupport = true,
	insertReplaceSupport = true,
	labelDetailsSupport = true,
	deprecatedSupport = true,
	commitCharactersSupport = true,
	tagSupport = { valueSet = { 1 } },
	resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	},
}

-- Semantic tokens capability
capabilities.textDocument.semanticTokens = {
	dynamicRegistration = false,
	tokenTypes = {
		"namespace",
		"type",
		"class",
		"enum",
		"interface",
		"struct",
		"typeParameter",
		"parameter",
		"variable",
		"property",
		"enumMember",
		"event",
		"function",
		"method",
		"macro",
		"keyword",
		"modifier",
		"comment",
		"string",
		"number",
		"regexp",
		"operator",
	},
	tokenModifiers = {
		"declaration",
		"definition",
		"readonly",
		"static",
		"deprecated",
		"abstract",
		"async",
		"modification",
		"documentation",
		"defaultLibrary",
	},
	formats = { "relative" },
	requests = {
		range = true,
		full = {
			delta = true,
		},
	},
}

-- 1. Глобальный дефолт для всех LSP конфигураций:
-- сюда кладем capabilities, чтобы не дублировать в каждом сервере
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- 2. Индивидуальные конфиги серверов

-- Lua (lua_ls)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

-- TypeScript / JS (ts_ls)
vim.lsp.config("ts_ls", {
	-- можно расширять настройку ts_ls здесь при необходимости
})

-- templ (Go html templating или templ язык)
vim.lsp.config("templ", {
	-- сюда можно добавить что нужно для templ, если нужно
})

-- CSS
vim.lsp.config("cssls", {
	-- доп. настройки cssls можно положить сюда
})

-- PHP
vim.lsp.config("intelephense", {
	-- кастомные настройки для PHP сервера intelephense можно положить сюда
})

-- Tailwind CSS
vim.lsp.config("tailwindcss", {
	-- индивидуальные настройки tailwindcss сервера можно положить сюда
})

-- Go (gopls) со всеми твоими анализаторами, подсказками и линзами
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				ST1003 = true,
				fieldalignment = false,
				fillreturns = true,
				nilness = true,
				nonewvars = true,
				shadow = true,
				undeclaredname = true,
				unreachable = true,
				unusedparams = true,
				unusedwrite = true,
				useany = true,
			},
			codelenses = {
				gc_details = true,
				generate = true,
				regenerate_cgo = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			buildFlags = { "-tags", "integration" },
			completeUnimported = true,
			diagnosticsDelay = "500ms",
			matcher = "Fuzzy",
			semanticTokens = true,
			staticcheck = true,
			symbolMatcher = "fuzzy",
			usePlaceholders = true,
		},
	},
})

-- 3. Включаем все нужные LSP-конфиги
-- После этого они будут автоматически подниматься на нужных filetype
vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"templ",
	"cssls",
	"gopls",
	"intelephense",
	"tailwindcss",
})
