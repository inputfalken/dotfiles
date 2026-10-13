-- Schemas from SchemaStore by file name, e.g. appsettings.json, launchSettings.json, global.json and package.json.
return {
  settings = {
    json = {
      validate = { enable = true },
    },
  },
  -- Deferred to server start, since mason-lspconfig resolves every installed server's config at startup.
  before_init = function(_, config)
    config.settings.json.schemas = require('schemastore').json.schemas()
  end,
}
