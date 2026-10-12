local M = {}

-- M.editar_padrao = false
M.edit_default= false

-- M.colar_depois = false	-- nvim_put(.after)
M.paste_after = false	-- nvim_put(.after)
-- |a| <- Cursor
-- follow = true
-- a|a|a -> aXXX|a|a
-- follow = false
-- a|a|a -> aXX|X|aa
--
-- nvim_put(.follow)
-- M.colar_mover_cursor = false
M.paste_move_cursor = false
-- M.nova_linha = false
M.new_line = false

-- M.altura_lista = nil
M.list_height = nil

-- Normalmente `pre_count` se refere ao último `count` passado, mas pode ficar meio estranho se você pedir para repetir o último e/ou passar um novo `count`.
-- "passar `count`" se refere a qualquer count diferente de 1.
-- 0 => Faz o `pre_count` ser *sempre* o último `count` (não passar é o mesmo que `count` 1):
-- `count` = x|0, colar(~, true|false); `pre_count` = `count`
--
-- 1 => Se repetir_ultimo_count == true, *sempre* mantém o valor do `pre_count` (mantém o último `count` utilizado):
-- `count` = x|0, colar(~, false); `pre_count` = `count`
-- `count` = x|0, colar(~, true); `pre_count` = `pre_count`
--
-- 2 => Faz o `pre_count` ser o último `count` ao menos que passe `count` e repetir_ultimo_count = true.
-- O mesmo que 0 a menos que passe `count` e repetir_ultimo_count = true:
-- `count` = x, colar(~, true|false); `pre_count` = `count`
-- `count` = 0, colar(~, false); `pre_count` = 1 (não passar count é o mesmo que passar 1)
-- `count` = 0, colar(~, true); `pre_count` = `pre_count`
--
-- | repetir_ultimo_count | `count` |                `pre_count`                    |
-- | -------------------- | ------- | --------------------------------------------- |
-- |        false         |  false  |    1    (0),      1      (1),      1      (2) |		// Efetivamente o mesmo que passar `count` 1 (não é a toa que tem os mesmos resultados que a 3ª linha se o `count` for 1)
-- |        true          |  false  |    1    (0), `pre_count` (1), `pre_count` (2) |		// Repetir o último
-- |        false         |  true   | `count` (0),   `count`   (1),   `count`   (2) |		// Passar `count` diretamente
-- |        true          |  true   | `count` (0), `pre_count` (1),   `count`   (2) |		// Repetir para o último para o comando mesmo passando `count`
-- M.novo_count = 1
M.new_count = 1

return M
