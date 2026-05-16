local M = {}
-- Se for um repositório git se basei na pasta raiz do git, se não pega a pasta onde abriu o neovim
function M.pasta_raiz()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

    if vim.v.shell_error == 0 then
        return git_root
    end

    return vim.fn.getcwd()
end

M.dir_config = vim.fn.stdpath('data') .. "/meuclipboard/"

return M
