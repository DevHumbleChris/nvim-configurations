require("nvchad.configs.lspconfig").defaults()
local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

-- Helper function to get TypeScript SDK path
local function get_typescript_lib_path()
    local global_node_modules = os.getenv("HOME") .. "/.nvm/versions/node/*/lib/node_modules"
    local local_node_modules = "node_modules"
    
    -- Check for TypeScript in local node_modules first
    local local_tsdk = vim.fn.glob(local_node_modules .. "/typescript/lib")
    if local_tsdk ~= "" then
        return local_tsdk
    end
    
    -- Fall back to global installation
    local global_tsdk = vim.fn.glob(global_node_modules .. "/typescript/lib")
    if global_tsdk ~= "" then
        return global_tsdk
    end
    
    return nil
end

local servers = { "html", "cssls", "gopls", "volar" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  if lsp ~= "volar" then  -- Skip volar as we configure it separately
    lspconfig[lsp].setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end
end

-- Volar configuration with dynamic TypeScript SDK path
local ts_sdk_path = get_typescript_lib_path()
if ts_sdk_path then
    lspconfig.volar.setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
        init_options = {
            typescript = {
                tsdk = ts_sdk_path
            },
            vue = {
                hybridMode = true
            }
        }
    }
else
    -- Fallback configuration if TypeScript is not found
    lspconfig.volar.setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
        filetypes = { 'vue' }
    }
    vim.notify("TypeScript SDK not found. Vue language features might be limited.", vim.log.levels.WARN)
end

-- Your existing configurations...
lspconfig.gopls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true
      }
    }
  }
}