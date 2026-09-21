vim.api.nvim_create_user_command("Meusalvar", function(argumentos)
		require("meuclipboard").salvar(argumentos.args)
	end, { nargs =  1 })

vim.api.nvim_create_user_command("Meucolar",function() require("meuclipboard").colar() end, {})

--vim.api.nvim_create_autocmd("DirChanged", { callback = function()
--	local lgit_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
--	if vim.v.shell_error == 0 then
--		require("meuclipboard").vpasta_raiz = lgit_root
--	else
--		require("meuclipboard").vpasta_raiz = vim.fn.getcwd()
--	end
--
--	require("meuclipboard").transferencia = vim.fn.readfile(require("meuclipboard").dir_config .. require("meuclipboard").vpasta_raiz:gsub("[/\\]", "_") .. ".txt")
--end })
