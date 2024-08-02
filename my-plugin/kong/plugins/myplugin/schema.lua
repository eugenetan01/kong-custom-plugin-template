local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name
local plugin_name = ({ ... })[1]:match("^kong%.plugins%.([^%.]+)")

local schema = {
    name = plugin_name,
    fields = {
        -- the 'fields' array is the top-level entry with fields defined by Kong
        { consumer = typedefs.no_consumer }, -- this plugin cannot be configured on a consumer (typical for auth plugins)
        { protocols = typedefs.protocols_http },
        {
            config = {
                -- The 'config' record is the custom part of the plugin schema
                type = "record",
                fields = {
                    -- a standard defined field (typedef), with some customizations
                    {
                        authentication_url = { -- self defined field, you can add an auth url in the Kong manager UI when configuring the plugin
                            type = "string",
                            default = "http://authservice:8080/auth/validate/token",
                            required = true,
                        }
                    },
                    {
                        authorization_url = { -- self defined field, you can add an auth url in the Kong manager UI when configuring the plugin
                            type = "string",
                            default = "http://authservice:8080/auth/validate/customer",
                            required = true,
                        }
                    },
                },
            },
        },
    },
}

return schema
