local M = {}

M.configs = require("meuclipboard.configs")



M.dir_config = vim.fn.stdpath('data') .. "/meuclipboard/"

local lgit_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
M.vroot_folder = ''
if vim.v.shell_error == 0 then
	M.vroot_folder = lgit_root
else
	M.vroot_folder = vim.fn.getcwd()
end


if vim.uv.fs_stat(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt") then
	M.clipboard = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")
end

-- function M.pasta_raiz()
--     local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
--
--     if vim.v.shell_error == 0 then
--         return git_root
--     end
--
--     return vim.fn.getcwd()
-- end

-- Base: Salvar e colar
-- Base: Save and paste
-- // ----------------------------------------------------------

---@param data? string
-- Usa o prompt do neovim para salvar o texto que deseja
-- Uses neovim prompt to save the desired text
function M.save(data)
	if not data then
		data = vim.fn.input({ prompt = "Text to save: "})
	end

	if data == "" then
		return
	end

	vim.fn.writefile({ data }, M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt", "a")
end

---@param data? string
-- Mesmo que `save()`, porém em vez do prompt do neovim, `vim.fn.input()`, usa uma caixa flutuante, `vim.ui.input()`.
-- REQUER `dressing.nvim`
-----
-- Same as `save()`, however instead of using neovim's prompt, `vim.fn.input()`, it uses a floating box, `vim.ui.input()`.
-- REQUIRES `dressing.nvim`
--_`TODO:` Mudar para snacks.nvim_
function M.salvarP(data)
	if not data then
		vim.ui.input({ prompt = "Texto para salvar: " }, function(input) data = input end)
	end

	if data == "" then
		return
	end

	vim.fn.writefile({ data }, M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt", "a")
end

M.pre_index = 1
M.pre_count = 1

---@param repeat_last_index? boolean 
---@param repeat_last_count? boolean
---@return integer|nil
function M.paste(repeat_last_index, repeat_last_count)
	local index
	local count

	if repeat_last_index then
		index = M.pre_index
	else
		index = tonumber(vim.fn.input({ prompt = "Index : "}))
	end

	if repeat_last_count then
		count = M.pre_count
	else
		count = vim.v.count1
	end

	if M.configs.new_count == 0 then
		M.pre_count = vim.v.count1
		-- print("[0]: " .. M.pre_count)
	elseif M.configs.new_count == 1 and not repeat_last_count then
		M.pre_count = vim.v.count1
		-- print("[1]: " .. M.pre_count)
	elseif M.configs.new_count == 2 and not (repeat_last_count and vim.v.count1 == 1) then
		M.pre_count = vim.v.count1
		-- print("[2]: " .. M.pre_count)
	end

    if not index or index % 1 ~= 0 then
		print("Invalid number.")
		return
    end

	local text = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")[index]
	if not text then
		print("Inexisting item.")
		return
	end

	if M.configs.new_line then
		local temp = {}
		for _ = 1, count do
				table.insert(temp, text)
		end
		vim.api.nvim_put(temp, 'c', M.configs.paste_after, M.configs.paste_move_cursor)
	else
		vim.api.nvim_put({ string.rep(text, count) }, 'c', M.configs.paste_after, M.configs.paste_move_cursor)
	end

	M.pre_index = index
	return index
end

-- Listas
-- // -----------------------

---@param opts? any
function M.procurarTelescope(opts)
	local texto = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")

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
				vim.api.nvim_put({ selection[1] }, "", M.configs.paste_after, M.configs.paste_move_cursor)

			end)
			return true
		end,

	}):find()
end

function M.mostrarLista()
	local texto = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")

	-- TODO: Entender os argumentos
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, texto)

	local width = 40
	local height

	if M.configs.altura_lista then
		height = M.configs.altura_lista
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
		M.pre_index = lline
		M.paste(true)
	end, { buffer = buf })

	vim.keymap.set("n", "x", function()
		local lline
		if vim.v.count > 0 then
			lline = vim.v.count1
			vim.cmd("normal! <C-u>")	-- Meio hacky. Serve pra consumir o count
		else
			lline = vim.api.nvim_win_get_cursor(win)[1]
		end

		M.remover(lline)
		vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
		texto = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, texto)
		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

		vim.api.nvim_win_set_config(win, { width = width, height = #texto})
	end, { buffer = buf })
end

-- Edição
-- // -----------------------

---@param index? integer
function M.editar(index)
	-- Aceita tanto 0 como 1 em cursor()
	-- if index and index < 0 then
	-- 	if M.configs.editar_padrao then
	-- 		print("Index inválido. Utilizando 1. [editar_padrao = true]")
	-- 		index = 1
	-- 	else
	-- 		print("Index inválido.")
	-- 		return
	-- 	end
	-- end

	if vim.v.count ~= 0 then
		index = vim.v.count
	elseif index and index < 0 then
		if M.configs.editar_padrao then
			print("Index inválido. Utilizando 1. [editar_padrao = true]")
			index = 1
		else
			print("Index inválido.")
			return
		end
	elseif not index then
		index = 1
	end

	vim.cmd("tabnew " .. M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")

	vim.fn.cursor(index, 1)
end

---@param index? integer
--Remove um item do projeto atual
function M.remover(index)
	if not index then
		index = tonumber(vim.fn.input({ prompt = "Indexi pra excluir: "}))
		if not index or index % 1 ~= 0 then
			print("Número inválido.")
			return
		end
	end

	local texto = vim.fn.readfile(M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")

	table.remove(texto, index)
	vim.fn.writefile(texto, M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt")
end

---@param caminho? string
--Apaga o arquivo inteiro
--Cuidado ao passar um caminho. Pois vai excluir o arquivo mesmo que não seja do plugin.
--Preferível não passar nada, que usa o do projeto/pasta atual.
function M.limpar(caminho)
	if not caminho then
		caminho = M.dir_config .. M.vroot_folder:gsub("[/\\]", "_") .. ".txt"
	end

	vim.fn.delete(caminho)
end

-- Extra
-- // -----------------------

--TODO:
-- M.nl = M.extra.nl


-- { "<leader>,s", M.salvar }
-- { "<leader>,p", M.colar, { silent = true } }
-- { "<C-p>", M.colar, nil, "i" }
local acoes = {
	salvar = { M.save, { "n", "v" } },
	salvarP = { M.salvarP, { "n", "v" } },
	colar = { M.paste, { "n", "v" }  },
	colar_repetir = { function() M.paste(true, false) end, { "n", "v" }  },
	editar = { M.editar, { "n", "v" }  },
	remover = { M.remover, { "n", "v" }  },
	editar_index = { function() M.editar(tonumber(vim.fn.input({ prompt = "Index: "}))) end, { "n", "v" }  },
	lista = { M.mostrarLista, { "n", "v" } },
	telescope = { function() M.procurarTelescope(require("telescope.themes").get_ivy({})) end, { "n", "v" }  },

	nova_linha = { function()
		M.configs.new_line = not M.configs.new_line
		print("Nova linha: " .. tostring(M.configs.new_line))
	end, { "n", "v" } }
}

M.maps = {
    salvar = "<leader>,s",
    salvarP = "<leader>,S",
    colar = "<leader>,,",
	colar_repetir = "<leader>,.",
    editar = "<leader>,E",
    remover = "<leader>,r",
	editar_index = "<leader>,l",
    lista = "<leader>,e",
    telescope = "<leader>,t",
	nova_linha = "<leader>, "
}

---@class Opts
---@field maps? table
---@field merge_maps? boolean
---@field map_opts? table
---@field editar_padrao? boolean
---@field colar_depois? boolean
---@field colar_mover_cursor? boolean
---@field nova_linha? boolean
---@field altura_lista? integer
---@field novo_count? integer
---@field verificar_pasta? boolean

---@param opts? Opts
function M.setup(opts)
	opts = opts or {}
	opts.map_opts = opts.map_opts or {}

	-- // ---
	if opts.editar_padrao then
		M.configs.editar_padrao = true
	end
	if opts.colar_depois then
		M.configs.paste_after = true
	end
	if opts.colar_mover_cursor == false then
		M.configs.paste_move_cursor = false
	end
	if opts.nova_linha then
		M.configs.new_line = true
	end
	if opts.altura_lista then
		M.configs.altura_lista = opts.altura_lista
		-- print(M.configs.altura_lista)
	end
	if opts.novo_count then
		M.configs.new_count = opts.novo_count
	end
	if opts.verificar_pasta == false then
		vim.api.nvim_create_autocmd("DirChanged", { callback = function()
			lgit_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
			if vim.v.shell_error == 0 then
				require("meuclipboard").vpasta_raiz = lgit_root
			else
				require("meuclipboard").vpasta_raiz = vim.fn.getcwd()
			end

			require("meuclipboard").transferencia = vim.fn.readfile(require("meuclipboard").dir_config .. require("meuclipboard").vpasta_raiz:gsub("[/\\]", "_") .. ".txt")
		end })
	end
	-- // ---

	if opts.maps then
		-- Mais fácil ler os ifs ao contrário (not opts.merge_maps)
		if opts.merge_maps then
			M.maps = vim.tbl_deep_extend(
				"force",
				vim.deepcopy(M.maps),
				opts.maps
			)
		else
			M.maps = opts.maps
		end
	end
	for acao, lhs in pairs(M.maps) do
		if lhs then
			vim.keymap.set(acoes[acao][2] or { "n", "v" }, lhs, acoes[acao][1], opts.map_opts[acao])
		end
	end

	vim.fn.mkdir(M.dir_config, "p")
end

return M
