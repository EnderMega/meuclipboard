local M = {}

local configs = require("meuclipboard.configs")
local locais = require("meuclipboard.locais")

-- TODO: Aceitar count
---@param index? integer
function M.editar(index)
	-- Aceita tanto 0 como 1 em cursor()
	if index and index < 0 then
		if configs.editar_padrao then
			print("Index inválido. Utilizando 1. [editar_padrao = true]")
			index = 1
		else
			print("Index inválido.")
			return
		end
	end

	vim.cmd("tabnew " .. locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

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

	local texto = vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")

	table.remove(texto, index)
	vim.fn.writefile(texto, locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")
end

---@param caminho? string
--Apaga o arquivo inteiro
--Cuidado ao passar um caminho. Pois vai excluir o arquivo mesmo que não seja do plugin.
--Preferível não passar nada, que usa o do projeto/pasta atual.
function M.limpar(caminho)
	if not caminho then
		caminho = locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt"
	end

	vim.fn.delete(caminho)
end

return M
