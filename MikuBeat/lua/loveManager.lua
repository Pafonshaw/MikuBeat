
local require = require
local activity = activity
local pcall = pcall
local io = io
local table = table
local tointeger = tointeger
local bindClass = luajava.bindClass

local File = bindClass "java.io.File"
local cjson = require "cjson"
local myToast = require "myToast"



local _M = {}

local lovePath = activity.getExternalFilesDir(nil).getPath().."/music/love.json" --用户添加文件路径

function _M.getLoveMusic()
  local loveFile = io.open(lovePath, "r") --r模式打开文件，可判断文件是否存在并在存在时读取
  if loveFile then --如果存在，继续操作，否则跳到返回空表
    local loves = loveFile:read("*a") --读取文件
    loveFile:close() --关闭文件
    if loves ~= "" then --如果不是空文件，继续操作，否则跳到返回空表
      local ok
      ok, loves = pcall(cjson.decode, loves) --将json转为table
      if ok then --如果转换成功，返回转换结果，否则跳到返回空表
        return loves
      end
    end
  end
  return {}
end


function _M.addLoveMusic(info, from)
  local dir = activity.getExternalFilesDir(nil).getPath().."/music/cache/"
  local loves = _M.getLoveMusic()
  loves[#loves + 1] = {
    ["info"] = info,
    ["from"] = from,
  }
  return io.open(lovePath, "w"):write(cjson.encode(loves)):close()
end

function _M.subLoveMusic(index)
  index = tointeger(index)
  local loves = _M.getLoveMusic()
  table.remove(loves, index)
  return io.open(lovePath, "w"):write(cjson.encode(loves)):close() --最后写入文件
end

function _M.subLoveMusic2(info)
  local loves = _M.getLoveMusic()
  local index
  for i = 1, #loves do
    if loves[i]["info"] == info
      index = i
      break
    end
  end
  if index then _M.subLoveMusic(index) end
end


function _M.isLoved(info)
  local loves = _M.getLoveMusic()
  for i=1, #loves
    if loves[i]["info"] == info
      return true
    end
  end
  return false
end


return _M

