local BasePlugin = require "kong.plugins.base_plugin"
local json2xml =require "kong.plugins.apig-response-transform.json2xml"
local cjson = require "cjson.safe"
local TransferPlugin = BasePlugin:extend()
local format = format
local contentType = contentType
local requestId

function TransferPlugin:new()
  TransferPlugin.super.new(self, "apig-response-transform")
end


function TransferPlugin:access(config)
  TransferPlugin.super.access(self)
  --获取请求参数中的format参数
 -- format = kong.request.get_query_arg("Format")
  format = config.format
  kong.log("format is",format)
  action = kong.request.get_query_arg("Action")
end

function TransferPlugin:header_filter(config)
  TransferPlugin.super.header_filter(self)
  --获取response header中的content-type和request-id
  contentType = kong.response.get_header("Content-Type")
  requestId = kong.response.get_header("Request-Id")
  --format参数为xml，需要转换为json，默认为xml
  --如果修改为json，需要清空content-length，因为修改了长度
  if format == "xml" or format == nil then
	if string.find(contentType,"application/json") then
	kong.response.set_header("Content_Type","application/xml")
	kong.response.clear_header("Content-Length")
	end  
  end
end

function TransferPlugin:body_filter(config)
  TransferPlugin.super.body_filter(self)
  --如果format参数为xml或null，同时响应body为json格式，进行转换
  if format == "xml" or format == nil then
     if string.find(contentType,"application/json") then
     --ngx.arg[1]为响应body，ngx.arg[2]为body结束标志位
	local chunk, eof = ngx.arg[1], ngx.arg[2]
	local buffered = ngx.ctx.buffered
	if not buffered then 
		buffered = {}
		ngx.ctx.buffered = buffered
	end
	--将所有buffer拼接起来
	if chunk ~= "" then
	buffered[#buffered+1] = chunk
	ngx.arg[1] = nil
	end
	--如果标志位为true说明body全部接收
	if eof then
	local whole = table.concat(buffered)
	--将json格式的body解析为lua table
	   whole = cjson.decode(whole)
	  --如果requestId不为空，才对json进行改造，为了区分是否遵循openapi规范
	   if requestId ~= nil then
	     --如果响应body为数组形式，将body包一层data并在data同级加一个requestid的键值对   
	      if json2xml.isArrayTable(whole) then
	         local m={}
	         m["requestId"]=requestId
	         m["data"]=whole
		 whole = m
	     --如果为json对象，直接给body添加一个requestid的键值对   	  
	      else
	         whole["requestId"]=requestId
	      end
	   end
	   --增加公共请求参数action的开关
	   if action ~=nil then
	      ngx.arg[1] = "<" .. action .. "Response" .. ">" .. json2xml.toxml(whole) .. "</" .. action .. "Response" .. ">"
	   else
	      ngx.arg[1]=json2xml.toxml(whole)
	   end
	   ngx.arg[2]=true
	   ngx.ctx.buffered = nil
	end
      end
  end
end


return TransferPlugin
