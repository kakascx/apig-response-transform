local typedefs = require "kong.db.schema.typedefs"
return {
    name = "<apig-response-transform>",
    fields = {
        {
            -- this plugin will only be applied to Services or Routes
            consumer = typedefs.no_consumer
        },
        {
            -- this plugin will only run within Nginx HTTP module
            protocols = typedefs.protocols_http
        },
        {
            config = {
                type = "record",
                fields = {
                    -- Describe your plugin's configuration's schema here.
		{format = {type="string",default = "xml",one_of={"xml","json"}}}
                },
            },
        },
    },
    entity_checks = {
        -- Describe your plugin's entity validation rules
    },
}
