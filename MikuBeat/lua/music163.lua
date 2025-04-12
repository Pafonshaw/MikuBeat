


local bindClass = luajava.bindClass
local require = require
local io = io
local string = string
local Http = Http
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local activity = activity
local xpcall = xpcall
local print = print
local Colors = Colors

local cjson = require "cjson"
local File = bindClass "java.io.File"
local _M = {}
local view = {}
local isInit = false
local Glide = bindClass "com.bumptech.glide.Glide"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local MarqueeTextView = activity.loadDex(activity.getLuaPath("libs/MarqueeTextView.dex")).loadClass("com.xiayu372.widget.MarqueeTextView")
local MaterialAlertDialogBuilder = bindClass "com.google.android.material.dialog.MaterialAlertDialogBuilder"
local dialog = MaterialAlertDialogBuilder(activity)
local myToast = require "myToast"
local LuaUtil = bindClass "com.androlua.LuaUtil"
local File = bindClass "java.io.File"

local cachePath = activity.getExternalFilesDir(nil).getPath().."/music/cache/"
local cacheCachePath = activity.getExternalFilesDir(nil).getPath().."/music/cache/cache/"

function _M.makeSureDir()
  if not io.isdir(cacheCachePath)
    File(cacheCachePath).mkdirs()
  end
end


--网易 分享链接转歌曲id
--@ param string sl 歌曲分享链接
--@ param getInt bool 可选，为true则返回int
--@ return string 歌曲id
function _M.sltoid(sl, getInt)
  local id = string.match(tostring(sl), "id=([0-9]-)&")
  if not id
    local http = require "http"
    pcall(function()
      local _, _, _, h = http.get(sl)
      id = string.match(h.location, "id=([0-9]-)&")
    end)
  end
  if getInt then
    id = tonumber(id)
  end
  return id
end

function _M.sltoid2(sl, func)
  Http.get(sl, function(code, content, _, header)
    local id = string.match(tostring(header), "Location=%[.-id=([0-9]-)&.-%],")
    func(id)
  end)
end

--网易 分享链接转歌曲直链(share link to song link)
--@ param string sl 分享链接(share link)
--@ return string 歌曲直链(song link)
function _M.sltosl(sl)
  return "https://music.163.com/song/media/outer/url?id="..string.match(sl, "id=([0-9]-)&")..".mp3"
end
--print(sltosl("https://y.music.163.com/m/song?id=36587576&uct2=GnPw5n7rmzJxVL1%2BFjBbUQ%3D%3D&fx-wechatnew=t1&fx-wxqd=t1&fx-wordtest=t2&fx-listentest=t3&H5_DownloadVIPGift=t1&playerUIModeId=76001&PlayerStyles_SynchronousSharing=t3&dlt=0846&app_version=9.2.22"))

--网易 歌曲id转歌曲直链
--@ param string/int id 歌曲id
--@ return string 歌曲直链
function _M.idtosl(id, func)
  return "https://music.163.com/song/media/outer/url?id="..tostring(id)..".mp3"
end



--通过id操作歌曲，必须用这个，才能确保音乐文件存在(不存在时下载，出错提示)
--@ param string/int id 歌曲id
--@ param function func callback回调函数
function _M.idGetMusic(id, func)
  local sp = cachePath..tostring(id)..".mp3"
  if File(sp).isFile()
    func(sp)
   else
    canClick = false
    myToast.toast("诶呀，这首歌有点儿不熟悉了，稍等下，我现在就去学(ÒωÓ๑ゝ∠)，可千万不要打断我的学习哦")
    local sl = _M.idtosl(id)
    Http.get(sl, function(code, content, _, header)
      if code == 302 or code == 301
        xpcall(function()
          sl = tostring(header)
          sl = string.match(sl, "Location=%[(.-)%],")
          local cacheSp = cacheCachePath..tostring(id)..".mp3"
          Http.download(sl, cacheSp, function(code)
            if code == 200
              File(cacheSp).renameTo(File(sp))
              func(sp)
             else
              canClick = true
              print("音频文件下载失败3")
            end
          end)
        end, function() print("音频文件下载失败2") canClick = true end)
       else
        canClick = true
        print("音频文件下载失败1")
      end
    end)
  end
end


--存储歌曲信息到本地
--@ param string/int id 歌曲id
--@ param table/json msg 歌曲信息，当为json时需要传参isJson为true
--@ param bool isJson 可选，当msg为json时需要设置为true
function _M.saveMsg(id, msg, isJson)
  --isJson = isJson and true or false
  local localPath = cachePath..tostring(id)..".json"
  if isJson then
    return io.open(localPath, "w"):write(msg):close()
   else
    local ok
    ok, msg = pcall(cjson.encode, msg)
    if ok then
      return io.open(localPath, "w"):write(msg):close()
     else
      return false
    end
  end
end

--网易 歌曲id获取歌曲封面直链,歌名,作者
--@ param string/int id 歌曲id
--@ param function func 回调函数
--@ callback table 包含歌曲信息的表
--[[
@ callback table
id 歌曲id
name 歌名
artist 作者
pic 歌曲封面直链
code 状态码
]]
function _M.get163Msg(id, func)
  func = func or function() print("get163Msg未设置回调函数") end
  local name, artist, pic
  Http.get("https://y.music.163.com/m/song?id="..tostring(id), function(code, content)
    if code == 200 then
      name, artist = string.match(content, '<meta property="og:title" content="(.-) %- (.-) %- .- %- 网易云音乐" />')
      pic = string.match(content, '<meta property="og:image" content="(.-)" />')
    end
    func({
      ["id"] = tostring(id),
      ["name"] = name:html(),
      ["artist"] = artist:html(),
      ["pic"] = pic,
      ["code"] = code,
      --["url"] = _M.idtosl(id),--此处用处不大且不利于模块化
    })
  end)
end

function _M.getLocalMsg(id)
  local localPath = cachePath..tostring(id)..".json"
  local localFile = io.open(localPath, "r")
  if localFile then
    local localMsg = localFile:read("*a")
    localFile:close()
    if localMsg ~= "" then
      local ok
      ok, localMsg = pcall(cjson.decode, localMsg)
      if ok then
        return localMsg
       else
        return {["code"]=402,["msg"]="Failed: json to table"}
      end
     else
      return {["code"]=401,["msg"]="Empty file"}
    end
   else
    return {["code"]=400,["msg"]="File not found"}
  end
end


function _M.idGetMsg(id, func)
  local localPath = cachePath..tostring(id)..".json"
  
  if File(localPath).isFile() then
    local msg = _M.getLocalMsg(id)

    if msg["code"] == 200
      return func(msg)
     else
      print(msg["code"], msg["msg"])
    end

  end

  local function cacheFunc(tab)
    if tab["code"] == 200
      _M.saveMsg(id, tab)
    end
    func(tab)
  end

  _M.get163Msg(id, cacheFunc)
end

function _M.saveToSD(id)
  local sp = cachePath..tostring(id)..".mp3"
  if File(sp).isFile()
    xpcall(function()
      local path = "/sdcard/Download/"..tostring(id)..".mp3"
      LuaUtil.copyDir(sp, path)
      local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
      MediaScannerConnection.scanFile(activity, {File(path).getAbsolutePath()}, {"audio/mpeg"}, function()
        myToast.toast("音频已保存(◍•ᴗ•◍)\n[File:"..path.."]")
      end)
      end, function()
      myToast.toast("保存失败惹 (*꒦ິ⌓꒦ີ)\ncopy error")
    end)
   else
    local sl = _M.idtosl(id)
    Http.get(sl, function(code, content, _, header)
      if code == 302 or code == 301
        xpcall(function()
          sl = tostring(header)
          sl = string.match(sl, "Location=%[(.-)%],")
          local cacheSp = cacheCachePath..tostring(id)..".mp3"
          Http.download(sl, cacheSp, function(code)
            if code == 200
              File(cacheSp).renameTo(File(sp))
              saveToSD(id)
             else
              print("音频文件下载失败6")
            end
          end)
        end, function() print("音频文件下载失败5") end)
       else
        print("音频文件下载失败4")
      end
    end)
  end
end


function _M.subMusicById(id)
  local sp = cachePath..tostring(id)..".mp3"
  if File(sp).isFile()
    File(sp).delete()
    myToast.toast("对MikuBeat施展了催眠，忘掉了id"..tostring(id).."的歌")
   else
    myToast.toast("可是我本来就不会这首歌啊(ー ー゛)")
  end
end

local md5 = require "md5"

local function MD5(k)
  local k = md5.sum(k)
  return (string.gsub(k, ".", function (c)
    return string.format("%02x", string.byte(c))
  end))
end

local musicQuality = activity.getSharedData("musicQuality") or "standard"

function _M.watchMV(id, player, func, view)
  local getTokenUrl = "https://api.toubiec.cn/api/get-token.php"
  local apiUrl = "https://api.toubiec.cn/api/music_v1.php"
  local header = {
    ["User-Agent"] = "Mozilla/5.0 (Linux; Android 11; CMA-AN00 Build/HONORCMA-AN00) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.93 Mobile Safari/537.36",
  }
  local datas = {
    "url": "https://y.music.163.com/m/song?id="..tostring(id),
    "level": musicQuality,
    "type": "song",
  }
  Http.post(getTokenUrl, "", function(code, content)
    if code == 200
      token = cjson.decode(content)["token"]
      token2 = MD5(token)
      header["Authorization"]="Bearer "..token
      datas["token"]=token2
      Http.post(apiUrl, cjson.encode(datas), header, function(code, content)
        local msgs = cjson.decode(content)
        if msgs["status"] == 200
          local url = msgs["mv_info"]["url"]
          if string.find(url, "http")
            local Intent = bindClass "android.content.Intent"
            local Uri = bindClass "android.net.Uri"
            local viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
            activity.startActivity(viewIntent)
            if player.isPlaying()
              player.pause()
              func("/res/imgs/play.png", view)
            end
           else
            myToast.toast("这首歌没有MV哦~")
          end
         else
          print("解析失败")
        end
      end)
     else
      print("E: failed to get token.")
    end
  end)
end


local layout = {
  LinearLayoutCompat,
  layout_width=-1,
  orientation=1,
  {
    MarqueeTextView,
    id="title",
    layout_marginLeft="36dp",
    layout_marginRight="36dp",
    layout_marginTop="16dp",
    layout_marginBottom="16dp",
    textSize="32sp",
    textColor=Colors.colorOnBackground,
  },
  {
    MaterialCardView,
    layout_gravity="center",
    {
      AppCompatImageView,
      id="cover",
      layout_width="230dp",
      layout_height="230dp",
    },
  },
  {
    MaterialCardView,
    layout_marginTop="24dp",
    layout_marginBottom="16dp",
    layout_gravity="center",
    layout_marginLeft="28dp",
    layout_marginRight="28dp",
    layout_width=-1,
    {
      LinearLayoutCompat,
      layout_width=-1,
      layout_height=-1,
      {
        LinearLayoutCompat,
        layout_weight=1,
        layout_width=1,
        layout_height=-1,
        gravity="center",
        backgroundColor=Colors.colorSurfaceVariant,
        {
          AppCompatTextView,
          textSize="24sp",
          text="收藏:",
          textColor=Colors.colorOnBackground,
        },
      },
      {
        LinearLayoutCompat,
        layout_width=1,
        layout_weight=1,
        layout_height=-1,
        gravity="center",
        backgroundColor=Colors.colorSurfaceContainer,
        {
          AppCompatTextView,
          id="isLove",
          textSize="24sp",
          textColor=Colors.colorOnBackground,
        },
      },
    },
  },
  {
    MaterialCardView,
    layout_marginBottom="24dp",
    layout_gravity="center",
    layout_marginLeft="28dp",
    layout_marginRight="28dp",
    layout_width=-1,
    {
      LinearLayoutCompat,
      layout_width=-1,
      layout_height=-1,
      {
        LinearLayoutCompat,
        layout_weight=1,
        layout_width=1,
        layout_height=-1,
        gravity="center",
        backgroundColor=Colors.colorSurfaceVariant,
        {
          AppCompatTextView,
          textSize="24sp",
          text="来源:",
          textColor=Colors.colorOnBackground,
        },
      },
      {
        LinearLayoutCompat,
        layout_width=1,
        layout_weight=1,
        layout_height=-1,
        gravity="center",
        backgroundColor=Colors.colorSurfaceContainer,
        {
          AppCompatTextView,
          id="from",
          textSize="24sp",
          textColor=Colors.colorOnBackground,
        },
      },
    },
  },
}



local function initDialog()
  dialog.setView(loadlayout(layout, view))
  dialog.setCancelable(true)
  dialog = dialog.create()
  isInit = true
end


function _M.musicInfoDialog(id)
  if not isInit
    initDialog()
    isInit = true
  end
  _M.idGetMsg(id,function(msg)
    view.title.text = msg.name.."--"..msg.artist
    Glide.with(activity).load(msg.pic).into(view.cover)
    view.cover.onLongClick = function()
      Http.download(msg.pic, "/sdcard/Pictures/"..tostring(id)..".jpg",function(code)
        if code == 200 then
          local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
          MediaScannerConnection.scanFile(activity, {File("/sdcard/Pictures/"..tostring(id)..".jpg").getAbsolutePath()}, {"image/png"}, function()
            myToast.toast("封面已经下载好了꒰ *•ɷ•* ꒱\n[File:/sdcard/Pictures/"..tostring(id)..".jpg]")
          end)
         else
          myToast.toast("布豪，下载失败惹 o(╥﹏╥)o ")
        end
      end)
    end
    local loveManager = require "loveManager"
    view.isLove.text = loveManager.isLoved(id) and "已收藏" or "未收藏"
    view.from.text = "网易云音乐"
    dialog.show()
  end)
end



return _M

