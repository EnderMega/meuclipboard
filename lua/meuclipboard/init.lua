local M = {}

M.configs = require("meuclipboard.configs")
M.locais = require("meuclipboard.locais")

-- Base: Salvar e colar
-- // ----------------------------------------------------------

local base = require("meuclipboard.base")
M.salvar = base.salvar
M.salvarP = base.salvarP
M.colar = base.colar

-- Listas
-- // -----------------------

local listas = require("meuclipboard.listas")
M.procurarTelescope = listas.procurarTelescope
M.mostrarLista = listas.mostrarLista

-- Edição
-- // -----------------------

local edicao = require("meuclipboard.edicao")
M.editar = edicao.editar
M.remover = edicao.remover
M.limpar = edicao.limpar

-- Extra
-- // -----------------------

M.extra = require("meuclipboard.extras")
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
			M.configs.colar_follow = false
		end
		if opts.altura_lista then
			M.configs.altura_lista = opts.altura_lista
		end
	end

	vim.fn.mkdir(M.locais.dir_config, "p")
end

return M
