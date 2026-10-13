-- Schemas from SchemaStore.nvim instead of the server's own download, e.g. Azure Pipelines, GitHub Actions, docker-compose.
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = '' },
    },
  },
  -- Deferred to server start, since mason-lspconfig resolves every installed server's config at startup.
  before_init = function(_, config)
    config.settings.yaml.schemas = require('schemastore').yaml.schemas()
  end,
}
