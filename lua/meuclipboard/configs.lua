local M = {}

M.editar_padrao = false

M.colar_depois = false	-- nvim_put(.after)
-- follow = true
-- a|a|a -> aXXX|a|a
-- follow = false
-- a|a|a -> aXX|X|aa
--
-- nvim_put(.follow)
M.colar_follow = false
M.nova_linha = false

-- 0 => Faz o `pre_count` ser sempre o último count passado:
-- `pre_count` = y, count = x, colar(~, true|false); `pre_count` = x
--
-- 1 => Se repetir_ultimo_count == true e *passar* count, usa o valor do count como o novo `pre_count`:
-- `pre_count` = y, count = 0 (sem count), colar(~, true);  pre_count = y
-- `pre_count` = y, count = x,			   colar(~, true);  pre_count = x (count = 1 incluido)
-- `pre_count` = y, count = x,			   colar(~, false); pre_count = x (count = 1 incluido)
--
-- 2 => Se repetir_ultimo_count == true, sempre mantém mantém o valor do `pre_count`
-- `pre_count` = y, count = x (sem count, 0, e 1 incluido), colar(~, true); pre_count = y
M.novo_count = 1

M.altura_lista= nil

return M
