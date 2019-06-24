local BasePlugin = require "kong.plugins.base_plugin"
local json2xml =require "kong.plugins.apig-response-transform.json2xml"
local TransferPlugin = BasePlugin:extend()
local format = format
local contentType = contentType
local contentLength
local concat = table.concat

function TransferPlugin:new()
  TransferPlugin.super.new(self, "apig-response-transform")
end


function TransferPlugin:access(config)
  TransferPlugin.super.access(self)
  format = kong.request.get_query_arg("Format")
end

function TransferPlugin:header_filter(config)
  TransferPlugin.super.header_filter(self)
  contentType = kong.response.get_header("Content-Type")
  if format == "xml" or format == nil then
	if string.find(contentType,"application/json") then
	kong.response.set_header("Content_Type","application/xml")
	kong.response.clear_header("Content-Length")
	end  
  end
--  kong.log(contentType)
end

function TransferPlugin:body_filter(config)
  TransferPlugin.super.body_filter(self)
  if format == "xml" or format == nil then
     if string.find(contentType,"application/json") then		
	local chunk, eof = ngx.arg[1], ngx.arg[2]
	local buffered = ngx.ctx.buffered
	if not buffered then 
		buffered = {}
		ngx.ctx.buffered = buffered
	end
	if chunk ~= "" then
	buffered[#buffered+1] = chunk
	ngx.arg[1] = nil
	end
	if eof then
	local whole = table.concat(buffered)
	--kong.log("whole is",whole)
	ngx.ctx.buffered = nil
	whole = json2xml.toxml(config,whole)
	contentLength = string.len(whole)
	--kong.log("length is :",contentLength)
	--kong.log(whole)
	ngx.arg[1]=whole
	ngx.arg[2]=true
	end
	end
  end
end


return TransferPlugin
