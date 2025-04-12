

local _M = {}

local activity = activity
local bindClass = luajava.bindClass
local require = require
local io = io
local Http = Http
local string = string
local pcall = pcall
local xpcall = xpcall
local cjson = require "cjson"
local File = bindClass "java.io.File"
local tostring = tostring
local table = table
local print = print
local tointeger = tointeger

local historyPath = activity.getExternalFilesDir(nil).getPath().."/music/history.json" --历史记录文件路径



function _M.getHistory()
  local historyFile = io.open(historyPath, "r") --r模式打开文件，可判断文件是否存在并在存在时读取
  if historyFile then --如果存在，继续操作，否则跳到返回空表
    local historys = historyFile:read("*a") --读取文件
    historyFile:close() --关闭文件
    if historys ~= "" then --如果不是空文件，继续操作，否则跳到返回空表
      local ok
      ok, historys = pcall(cjson.decode, historys) --将json转为table
      if ok then --如果转换成功，返回转换结果，否则跳到返回空表
        return historys
      end
    end
  end
  return {}
end

--添加历史记录
--@ param int/string history 歌曲id
function _M.addHistory(history, from)
  local historys = _M.getHistory()
  if #historys ~= 0 and historys[#historys]["info"] == tostring(history) then --如果和上一条历史记录一样，不用添加
    return
   elseif #historys < 20 then --如果数量不足20个
    historys[#historys+1] = {
      ["info"] = history, --直接在末尾添加
      ["from"] = from,
    }
   elseif #historys == 20 then --如果已满20个
    table.remove(historys, 1)
    historys[20] = {
      ["info"] = history, --然后在末尾索引20处添加history
      ["from"] = from,
    }
   else --如果超过20条，打印一个布什戈门
    --不存在的情况
    return print("布什戈门，历史记录超出20个")
  end
  return io.open(historyPath, "w"):write(cjson.encode(historys)):close() --最后写入文件
end



function _M.subHistory(index)
  index = tointeger(index)
  local historys = _M.getHistory()
  table.remove(historys, index)
  return io.open(historyPath, "w"):write(cjson.encode(historys)):close() --最后写入文件
end

return _M

