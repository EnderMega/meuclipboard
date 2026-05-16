local M = {}

local configs = require("meuclipboard.configs")
local locais = require("meuclipboard.locais")

--TODO: Problema atual que o usuário pode ir e excluir a nova linha. E eu quero que o usuário possa mexer livremente no arquivo.
-- Além de que isso está virando um inferno de estados.

---@param val? boolean
--Se ao colar várias vezes deve colocar em uma nova linha cada elemento.
--Método persistente.
-- function M.nl(val)
-- 	if val ~= nil then
-- 		configs.nova_linha = val
-- 	else
-- 		configs.nova_linha = not configs.nova_linha
-- 	end
--
-- 	local texto = vim.fn.readfile(locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")
-- 	if texto[1] == '\n' then
-- 		table.remove(texto, 1)
-- 		configs.nova_linha = false
-- 	else
-- 		table.insert(texto, 1, '\n')
-- 		configs.nova_linha = true
-- 	end
--
-- 	print("Nova linha: " .. tostring(configs.nova_linha))
-- 	vim.fn.writefile(texto, locais.dir_config .. locais.pasta_raiz():gsub("[/\\]", "_") .. ".txt")
-- end

return M
