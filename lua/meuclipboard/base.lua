local M = {}

local configs = require("meuclipboard.configs")
local locais = require("meuclipboard.locais")

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

	vim.fn.writefile({ dados }, locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt", "a")
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

	vim.fn.writefile({ dados }, locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt", "a")
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

	local texto = vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")[index]
	if not texto then
		print("Item inexistente.")
		return
	end

	if configs.nova_linha then
		local temp = {}
		for _ = 1, count do
				table.insert(temp, texto)
		end
		vim.api.nvim_put(temp, 'c', configs.colar_depois, configs.colar_follow)
	else
		vim.api.nvim_put({ string.rep(texto, count) }, 'c', configs.colar_depois, configs.colar_follow)
	end

	M.pre_index = index
	return index
end

return M
