

local M = {}

local indentation = "" --缩进
local xml = ""
local str = ""


---firstToUpper 将字符串首字母大写
---@param str  需要改写的字符串
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

---isArrayTable
---@param t table 判断是否为数组类型的table
---@return boolean 数组类型返回true，否则返回false
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



---toxml 对json格式进行转换
---@param table table 由响应body转化而来的table数据
---@return string 返回xml格式数据
function M.toxml(tblBody)
    ProcessResponseBody(tblBody)
    local result = xml
    xml=""
    return result
end

---ProcessResponseBody 核心转换函数，通过递归将json转换为xml
---@param value table 需要转换的table格式的数据
---@return nil 动态更新xml字符串
function ProcessResponseBody(value)
    if type(value) == "string" then
        str = str .. indentation ..firstToUpper(value) .. "\n"
        xml = xml .. str
        str = " "
    elseif type(value) == "table" then
        for name,data in pairs(value) do
            --如果key为字符串，也就是说是json对象
            if type(name) == "string" then
                if type(data) == "string" then
                    str = str .. indentation .."<" .. firstToUpper(name) .. ">" .. data .. "</" .. firstToUpper(name) .. ">\n"
                    xml = xml .. str
                    str = ""

                elseif type(data) == "number" or type(data) == "boolean" then
                    str =  str .. indentation .. "<" ..firstToUpper(name) .. ">" .. tostring(data) .. "</" .. firstToUpper(name) .. ">\n"
                    xml = xml .. str
                    str = ""
                elseif type(data) == "table" then
                    --如果是数组类型的table，则遍历table并给每个元素添加标签
                    if M.isArrayTable(data) then
                        for tblName,tblData in pairs(data) do
                            xml = xml .. indentation .. "<" .. firstToUpper(name) .. ">\n"
                            indentation = indentation .. "\t"
                            ProcessResponseBody(tblData)
                            indentation = indentation:sub(1,#indentation-1)
                            str = str .. indentation .."</" .. firstToUpper(name) .. ">\n"
                            xml = xml .. str
                            str = " "
                        end
                    --如果是json对象，加标签后对内容进行遍历
                    else
                        xml = xml .. indentation .. "<" .. firstToUpper(name) .. ">\n"
                        indentation = indentation .. "\t"
                        ProcessResponseBody(data)
                        indentation = indentation:sub(1,#indentation-1)
                        str = str .. indentation .."</" .. firstToUpper(name) .. ">\n"
                        xml = xml .. str
                        str = " "
                    end
                end
            end
        end
    end
end

return M

