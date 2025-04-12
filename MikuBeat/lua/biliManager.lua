
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
local Colors = Colors
local myToast = require "myToast"
local print = print

local _M = {}

local cachePath = activity.getExternalFilesDir(nil).getPath().."/music/cache/"
local cacheCachePath = activity.getExternalFilesDir(nil).getPath().."/music/cache/cache/"



function _M.getLocalMsg(bv)
  local localPath = cachePath..bv..".json"
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

function _M.getBiliMsg(bv, func)
  local header = {
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
    "Referer" = "https://www.bilibili.com/video/"..bv.."/",
  }
  local name, artist, cover
  Http.get("https://www.bilibili.com/video/"..bv, header, function(code, content)
    if code == 200
      artist, name = string.match(content, '<meta data%-vue%-meta="true" itemprop="author" name="author" content="(.-)"><meta data%-vue%-meta="true" itemprop="name" name="title" content="(.-)_哔哩哔哩.-ilibil.-">')
      cover = "http:"..string.match(content, '<link data%-vue%-meta="true" rel="apple%-touch%-icon" href="(.-)@.-">').."@600w_600h_1c.png"
    end
    --io.open("/sdcard/b.html", "w"):write(content):close()
    func({
      ["name"] = name:html(),
      ["artist"] = artist:html(),
      ["cover"] = cover,
      ["code"] = code,
    })
  end)
end

function _M.saveMsg(bv, msg, isJson)
  local localPath = cachePath..bv..".json"
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

function _M.bvGetMsg(bv, func)
  local localPath = cachePath..bv..".json"

  if File(localPath).isFile() then
    local msg = _M.getLocalMsg(bv)

    if msg["code"] == 200
      return func(msg)
     else
      print(msg["code"], msg["msg"])
    end

  end

  local function cacheFunc(tab)
    if tab["code"] == 200
      _M.saveMsg(bv, tab)
    end
    func(tab)
  end

  _M.getBiliMsg(bv, cacheFunc)
end



function _M.bvGetMusic(bv, func)
  local sp = cachePath..bv..".m4a"
  if File(sp).isFile()
    func(sp)
   else
    canClick = false
    myToast.toast("诶呀，这首歌有点儿不熟悉了，稍等下，我现在就去学(ÒωÓ๑ゝ∠)，可千万不要打断我的学习哦")
    local header = {
      "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
      "Referer" = "https://www.bilibili.com/video/"..bv.."/",
    }
    Http.get("https://www.bilibili.com/video/"..bv, header, function(code, content)
      if code == 200
        local playinfo = string.match(content, '<script>window.__playinfo__=(.-)</script>')
        if playinfo
          local ok
          ok, playinfo = pcall(cjson.decode, playinfo)
          if ok and playinfo
            local sl = ((((playinfo.data or {}).dash or {}).audio or {})[1] or {}).baseUrl -- 音视频分离版
            || (((playinfo.data or {}).durl or {})[1] or {}).url -- 旧时代单视频版
            local cacheSp = cacheCachePath..bv..".m4a"
            if sl
              Http.download(sl, cacheSp, "", header, function(code)
                if code == 200
                  File(cacheSp).renameTo(File(sp))
                  func(sp)
                 else
                  local sl = (((((playinfo.data or {}).dash or {}).audio or {})[1] or {}).backupUrl or {})[1]
                  || ((((playinfo.data or {}).durl or {})[1] or {}).backup_url or {})[1]
                  if sl
                    Http.download(sl, cacheSp, "", header, function(code)
                      if code == 200
                        File(cacheSp).renameTo(File(sp))
                        func(sp)
                       else
                        canClick = true
                        myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@bvDownload")
                      end
                    end)
                   else
                    canClick = true
                    myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@playinfo.decode")
                  end
                end
              end)
             else
              canClick = true
              myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@playinfo.decode")
            end
           else
            canClick = true
            myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@playinfo.decode")
          end
         else
          canClick = true
          myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@playinfo.match")
        end
       else
        canClick = true
        myToast.toast("好像出了点意料之外的问题呢∑(✘Д✘๑)@bvget")
      end
    end)
  end
end



function _M.saveToSD(bv)
  _M.bvGetMusic(bv, function(sp)
    xpcall(function()
      local path = "/sdcard/Download/"..bv..".m4a"
      local LuaUtil = bindClass "com.androlua.LuaUtil"
      LuaUtil.copyDir(sp, path)
      local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
      MediaScannerConnection.scanFile(activity, {File(path).getAbsolutePath()}, {"audio/mpeg"}, function()
        myToast.toast("音频已保存(◍•ᴗ•◍)\n[File:"..path.."]")
      end)
      end, function()
      myToast.toast("保存失败惹 (*꒦ິ⌓꒦ີ)\ncopy error")
    end)
  end)
end



function _M.watchMV(bv, player, func, view)
  local url = "https://m.bilibili.com/video/"..bv
  local Intent = bindClass "android.content.Intent"
  local Uri = bindClass "android.net.Uri"
  local viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
  activity.startActivity(viewIntent)
  if player.isPlaying()
    player.pause()
    func("/res/imgs/play.png", view)
  end
end


function _M.subMusicByBv(bv)
  local sp = cachePath..bv..".m4a"
  if File(sp).isFile()
    File(sp).delete()
    myToast.toast("对MikuBeat施展了催眠，忘掉了bv为"..bv.."的歌")
   else
    myToast.toast("可是我本来就不会这首歌啊(ー ー゛)")
  end
end




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


function _M.musicInfoDialog(bv)
  if not isInit
    initDialog()
    isInit = true
  end
  _M.bvGetMsg(bv,function(msg)
    view.title.text = msg.name.."--"..msg.artist
    Glide.with(activity).load(msg.cover).into(view.cover)
    view.cover.onLongClick = function()
      Http.download(msg.cover, "/sdcard/Pictures/"..bv..".png",function(code)
        if code == 200 then
          local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
          MediaScannerConnection.scanFile(activity, {File("/sdcard/Pictures/"..bv..".png").getAbsolutePath()}, {"image/png"}, function()
            myToast.toast("封面已经下载好了꒰ *•ɷ•* ꒱\n[File:/sdcard/Pictures/"..bv..".png]")
          end)
         else
          myToast.toast("布豪，下载失败惹 o(╥﹏╥)o ")
        end
      end)
    end
    local loveManager = require "loveManager"
    view.isLove.text = loveManager.isLoved(bv) and "已收藏" or "未收藏"
    view.from.text = "Bilibili"
    dialog.show()
  end)
end




return _M
