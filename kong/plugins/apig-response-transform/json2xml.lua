
local cjson = require "cjson.safe"

local M = {}

local indentation = ""
local xml = ""
local str = ""
local result = ""

function M.toxml(config,bodyStr)
--	kong.log("in arg body Str is:",bodyStr)
    local value = cjson.decode(bodyStr)
    local t = type(value)

    if t == "table" then
        for name, data in pairs(value) do
           processInner(data)
            xml = "<" .. name .. ">\n" .. xml .. "</" .. name .. ">"
--		kong.log("xml is:",xml)
	    result = xml
            xml = ""
	    indentation = ""
        end
    end
    return result
end

function processInner(val)
    indentation = indentation .. "\t"
        for k,v in pairs(val) do
            if type(v) == "string" then
                str =  str .. indentation .. "<" .. k .. ">" .. v .. "</" .. k .. ">\n"
                xml = xml .. str
                str = " "
                elseif type(v) == "table" then
                for name, data in pairs(v) do
                    if type(name) == "number" then
                        if type(data) == "table" then
                            xml = xml .. indentation .. "<" .. k .. ">\n"
                            processInner(data)
			    indentation = indentation:sub(1,#indentation-1)
                            str = str .. indentation .."</" .. k .. ">\n"
                            xml = xml .. str
                            str = " "
                            elseif type(data) == "string" then
                            str = indentation .."<" .. k .. ">" .. data .. "</" .. k .. ">\n"
                            xml = xml .. str
                            str = " "
                        end

                    elseif type(data) == "table" and type(name) == "string" then
                        str = "<" .. name .. ">" .. processInner(data) .. "</" .. name .. ">"
                    elseif type(data) == "string" and type(name) == "string" then
                        str =  "<" .. name .. ">" .. data ..  "</" .. name .. ">\n"
                    end
          
                end
            end

        end

    return str
end

return M

