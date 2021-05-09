-- for k, v in pairs(table.foreach({"hello", "world"}, function(k, v) return {k, v} end)) do
--   print(k, v)
-- end
-- table.foreach({first = "hello", second = "world"}, function(k, v) print(k, v) end)

-- table.foreachi({"hello", "world"}, function(k, v) print(k, v) end)
-- table.foreachi({first = "hello", second = "world"}, function(k, v) print(k, v) end)

-- local file = io.open(filepath, "rb")
-- local source = file:read("*a")
-- file:close()

-- Parse the u_int32 string (little endian)
-- Ref:
-- https://stackoverflow.com/questions/5343598/how-do-i-convert-userdata-to-a-uint32-or-float
-- https://stackoverflow.com/questions/12344095/how-do-i-convert-a-cdata-structure-into-a-lua-string
-- https://stackoverflow.com/questions/829063/how-to-iterate-individual-characters-in-lua-string
-- local function parse_u_int32_le(str)
--   local hex = {}
--   str:gsub('.', function(c)
--     table.insert(hex, tonumber(string.format('%02X', string.byte(c)), 16))
--   end)

--   return hex[4] * 0x1000000 + hex[3] * 0x10000 + hex[2] * 0x100 + hex[1]
-- end

-- local header = string.sub(source, 1, 8)
-- assert(header == "mozLz40\0")
-- local destsize = parse_u_int32_le(string.sub(source, 9, 12))

-- source = string.sub(source, 13)

-- print(decompressed_data)

-- print(type(data))

-- -- print(vim.inspect(lz4))
-- local tmp = io.open("/tmp/decompressed_firefox_bookmarks", "w")
-- lz4.decompress(data, #data, tmp, 0)

-- local decomp = tmp:read()
-- print(decomp)
-- tmp:close()

--local utils = require('telescope.utils')
--local xml2lua = require("xml2lua")
----Uses a handler that converts the XML to a Lua table
--local handler = require("xmlhandler.tree")

--local plist_file = vim.loop.os_homedir() .. "/Library/Safari/Bookmarks.plist"
--local output, code, err = utils.get_os_command_output(
--  {"plutil",  "-convert", "xml1", "-o", "-", plist_file}
--)

--if code > 0 then
--  error(table.concat(err, "\n"))
--end

----Instantiates the XML parser
--local parser = xml2lua.parser(handler)
--parser:parse(output)

---- print(vim.inspect(handler.root))
