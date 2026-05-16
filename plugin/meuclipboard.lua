vim.api.nvim_create_user_command("Meusalvar", function(argumentos) -- argumentos é uma tabela que o neovim passa, o nome aqui pode ser qualquer coisa
		require("meuclipboard").salvar(argumentos.args)
	end, { nargs =  1 })
