local typedefs = require "kong.db.schema.typedefs"
return {
    name = "<apig-response-transform>",
    fields = {
        {
            -- this plugin will only be applied to Services or Routes
            consumer = typedefs.no_consumer
        },
        {
            -- this plugin will only be executed on the first Kong node
            -- if a request comes from a service mesh (when acting as
            -- a non-service mesh gateway, the nodes are always considered
            -- to be "first".
            run_on = typedefs.run_on_first
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
                },
            },
        },
    },
    entity_checks = {
        -- Describe your plugin's entity validation rules
    },
}
