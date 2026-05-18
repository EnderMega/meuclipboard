local M = {}

M.configs = require("meuclipboard.configs")

function M.pasta_raiz()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

    if vim.v.shell_error == 0 then
        return git_root
    end

    return vim.fn.getcwd()
end

M.dir_config = vim.fn.stdpath('data') .. "/meuclipboard/"

-- Base: Salvar e colar
-- // ----------------------------------------------------------

---@param dados? string
-- Usa o prompt do neovim para salvar o texto que deseja
function M.salvar(dados)
	if not dados then
		dados = vim.fn.input({ prompt = "Texto para salvar: "})
	end

	if dados == "" then
		return
	end

	vim.fn.writefile({ dados }, M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt", "a")
end

---@param dados? string
--Mesmo que `salvar()`, porém em vez do prompt do neovim, `vim.fn.input()`, usa uma caixa flutuante, `vim.ui.input()`.
--REQUER `dressing.nvim`
--_`TODO:` Mudar para snacks.nvim_
function M.salvarP(dados)
	if not dados then
		vim.ui.input({ prompt = "Texto para salvar: " }, function(entrada) dados = entrada end)
	end

	if dados == "" then
		return
	end

	vim.fn.writefile({ dados }, M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt", "a")
end

M.pre_index = 1
M.pre_count = 1

--Se repetir_ultimo_count == true ignora o count passado e muda o count baseado no novo_count
---@param repetir_ultimo_index? boolean 
---@return integer|nil
function M.colar(repetir_ultimo_index, repetir_ultimo_count)
	local index
	local count
	if repetir_ultimo_index then
		index = M.pre_index
	else
		index = tonumber(vim.fn.input({ prompt = "Index : "}))
	end
	if repetir_ultimo_count then
		count = M.pre_count
	else
		count = vim.v.count1
	end

    if not index or index % 1 ~= 0 then
		print("Número inválido.")
		return
    end

	local texto = vim.fn.readfile(M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")[index]
	if not texto then
		print("Item inexistente.")
		return
	end

	if M.configs.nova_linha then
		local temp = {}
		for _ = 1, count do
				table.insert(temp, texto)
		end
		vim.api.nvim_put(temp, 'c', M.configs.colar_depois, M.configs.colar_follow)
	else
		vim.api.nvim_put({ string.rep(texto, count) }, 'c', M.configs.colar_depois, M.configs.colar_follow)
	end

	M.pre_index = index
	return index
end

-- Listas
-- // -----------------------

---@param opts? any
function M.procurarTelescope(opts)
	local texto = vim.fn.readfile(M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

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
				vim.api.nvim_put({ selection[1] }, "", M.configs.colar_depois, M.configs.colar_follow)

			end)
			return true
		end,

	}):find()
end

function M.mostrarLista()
	local texto = vim.fn.readfile(M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

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
		M.colar(true)
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
		-- TODO: Atualizar o tamanho, ou ter um tamanho constante independente
		vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt"))
		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	end, { buffer = buf })
end

-- Edição
-- // -----------------------

-- TODO: Aceitar count
---@param index? integer
function M.editar(index)
	-- Aceita tanto 0 como 1 em cursor()
	if index and index < 0 then
		if M.configs.editar_padrao then
			print("Index inválido. Utilizando 1. [editar_padrao = true]")
			index = 1
		else
			print("Index inválido.")
			return
		end
	end

	vim.cmd("tabnew " .. M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

	if index then
		vim.fn.cursor(index, 1)
	end
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

	local texto = vim.fn.readfile(M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

	table.remove(texto, index)
	vim.fn.writefile(texto, M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt")
end

---@param caminho? string
--Apaga o arquivo inteiro
--Cuidado ao passar um caminho. Pois vai excluir o arquivo mesmo que não seja do plugin.
--Preferível não passar nada, que usa o do projeto/pasta atual.
function M.limpar(caminho)
	if not caminho then
		caminho = M.dir_config .. M.pasta_raiz():gsub("[/\\]", "_") .. ".txt"
	end

	vim.fn.delete(caminho)
end

-- Extra
-- // -----------------------

--TODO:
-- M.nl = M.extra.nl

---@param opts? table
function M.setup(opts)
	-- Se usa opts colocar aqui dentro
	if opts ~= nil then
		if opts.nova_linha then
			M.configs.nova_linha = true
		end
		if opts.editar_padrao then
			M.configs.editar_padrao = true
		end
		if opts.colar_antes then
			M.configs.colar_depois = true
		end
		if opts.colar_mover_cursor == false then
			M.colar_follow = false
		end
		if opts.altura_lista then
			M.altura_lista = opts.altura_lista
		end
	end

	vim.fn.mkdir(M.dir_config, "p")
end

return M
