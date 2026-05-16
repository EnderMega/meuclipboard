local M = {}

local configs = require("meuclipboard.configs")
local locais = require("meuclipboard.locais")
local base = require("meuclipboard.base")
local edicao = require("meuclipboard.edicao")

---@param opts? any
function M.procurarTelescope(opts)
	local texto = vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	opts = opts or {}

	pickers.new(opts, {
		prompt_title = "Meu clipboard",
		finder = finders.new_table({
			results = texto
		}),
		sorter = conf.generic_sorter(opts),

		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				vim.api.nvim_put({ selection[1] }, "", configs.colar_depois, configs.colar_follow)

			end)
			return true
		end,

	}):find()
end

function M.mostrarLista()
	local texto = vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

	-- TODO: Entender os argumentos
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, texto)

	local width = 40
	local height

	if configs.altura_lista then
		height = configs.altura_lista
	else
		height = #texto
	end

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "double",
	})
	vim.api.nvim_set_option_value("number", true, { win = win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = win })
	vim.api.nvim_set_option_value("cursorline", false, { win = win })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	-- vim.api.nvim_set_option_value("readonly", true, { buf = buf })

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.keymap.set("n", "<CR>", function()
		local lline
		if vim.v.count > 0 then
			lline = vim.v.count1
			vim.cmd("normal! <C-u>")	-- Meio hacky. Serve pra consumir o count
		else
			lline = vim.api.nvim_win_get_cursor(win)[1]
		end

		vim.api.nvim_win_close(win, true)
		base.pre_index = lline
		base.colar(true)
	end, { buffer = buf })

	vim.keymap.set("n", "x", function()
		local lline
		if vim.v.count > 0 then
			lline = vim.v.count1
			vim.cmd("normal! <C-u>")	-- Meio hacky. Serve pra consumir o count
		else
			lline = vim.api.nvim_win_get_cursor(win)[1]
		end

		edicao.remover(lline)
		-- TODO: Atualizar o tamanho, ou ter um tamanho constante independente
		vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt"))
		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	end, { buffer = buf })
end

return M
