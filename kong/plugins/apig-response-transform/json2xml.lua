

local M = {}

local indentation = ""
local xml = ""
local str = ""

--if table is an array
function M.isArrayTable(t)
    if type(t) ~= "table" then
        return false
    end

    local n = #t
    for i,v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end

        if i > n then
            return false
        end
    end

    return true
end

--transfer json to xml
function M.toxml(table)
    ProcessResponseBody(table)
    local result = xml
    xml=""
    return result
end

function ProcessResponseBody(value)
    if type(value) == "string" then
        str = str .. indentation ..value .. "\n"
        xml = xml .. str
        str = " "
    elseif type(value) == "table" then
        for name,data in pairs(value) do
            if type(name) == "string" then
                if type(data) == "string" then
                    --indentation = indentation .. "\t"
                    str = str .. indentation .."<" .. name .. ">" .. data .. "</" .. name .. ">\n"
                    xml = xml .. str
                    str = ""

                elseif type(data) == "number" or type(data) == "boolean" then
                    --indentation = indentation .. "\t"
                    str =  str .. indentation .. "<" .. name .. ">" .. tostring(data) .. "</" .. name .. ">\n"
                    xml = xml .. str
                    str = ""
                elseif type(data) == "table" then
                    if M.isArrayTable(data) then
                        for tblName,tblData in pairs(data) do
                            xml = xml .. indentation .. "<" .. name .. ">\n"
                            indentation = indentation .. "\t"
                            ProcessResponseBody(tblData)
                            indentation = indentation:sub(1,#indentation-1)
                            str = str .. indentation .."</" .. name .. ">\n"
                            xml = xml .. str
                            str = " "
                        end
                    else
                        xml = xml .. indentation .. "<" .. name .. ">\n"
                        indentation = indentation .. "\t"
                        ProcessResponseBody(data)
                        indentation = indentation:sub(1,#indentation-1)
                        str = str .. indentation .."</" .. name .. ">\n"
                        xml = xml .. str
                        str = " "
                    end
                end
            end
        end
    end
end

return M

