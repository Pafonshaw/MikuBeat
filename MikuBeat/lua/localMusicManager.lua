

local activity = activity
local bindClass = luajava.bindClass
local require = require
local io = io
local Http = Http
local pcall = pcall
local table = table
local tostring = tostring
local Colors = Colors

local MediaStore = bindClass "android.provider.MediaStore"
local FileOutputStream = bindClass "java.io.FileOutputStream"
local File = bindClass "java.io.File"
local BufferedOutputStream = bindClass "java.io.BufferedOutputStream"
local Bitmap = bindClass "android.graphics.Bitmap"
local cjson = require "cjson"
local BitmapFactory = bindClass "android.graphics.BitmapFactory"
local MediaMetadataRetriever = bindClass "android.media.MediaMetadataRetriever"

local _M = {}

local localPath = activity.getExternalFilesDir(nil).getPath().."/music/local.json"
local coverPath = activity.getExternalFilesDir(nil).getPath().."/music/cover/"
--封面
if not io.isdir(coverPath)
  File(coverPath).mkdirs()
end

--bitmap存储，用于存储本地音频封面
local function bitmapToFile(bitmap,path)
  io.open(path, "w"):close()
  local myCaptureFile = File(path)
  local fos = FileOutputStream(myCaptureFile)
  local bos = BufferedOutputStream(fos)
  local ok = pcall(function()
    bitmap.compress(Bitmap.CompressFormat.PNG,80,bos)
  end)
  bos.flush()
  bos.close()
  fos.close()
  return ok
end

function _M:new()
  return setmetatable({
    ["musics"] = {},
    },{
    __index = _M
  })
end

function _M:getAllAudio()
  local contentResolver = activity.getContentResolver()
  local Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
  local projection = {"_id", "title", "_data", "duration"}
  local sortOrder = "title ASC" -- 按标题升序排列
  local mCursor = contentResolver.query(Uri, projection, "duration >= ?", {activity.getSharedData("localMusicSearchTime") or "5000"}, sortOrder)

  while mCursor.moveToNext() do
    local id = mCursor.getString(mCursor.getColumnIndex("_id"))
    local title = mCursor.getString(mCursor.getColumnIndex("title"))
    --local artist = mCursor.getString(mCursor.getColumnIndex("artist"))
    local path = mCursor.getString(mCursor.getColumnIndex("_data"))

    if not File(path).isFile() continue end --检查文件存在

    local metaData = MediaMetadataRetriever()
    metaData.setDataSource(path)
    local cover = metaData.getEmbeddedPicture()
    metaData.release()
    local coverResult
    if cover
      cover = BitmapFactory.decodeByteArray(cover, 0, #cover)
      if cover
        if bitmapToFile(cover, coverPath..tostring(id)..".png")
          coverResult = coverPath..tostring(id)..".png"
        end
      end
    end
    coverResult = coverResult or false

    table.insert(self.musics, {
      ["id"] = id,
      ["title"] = title,
      --["artist"] = artist,
      --["path"] = path,
      ["cover"] = coverResult,
      ["from"] = "local",
      ["info"] = path,
    })
  end


  mCursor.close()
  io.open(localPath, "w")
  :write(cjson.encode(self.musics))
  :close()
end

function _M.getCacheMsgs()
  if File(localPath).isFile()
    local file = io.open(localPath, "r")
    local msgs = file:read("*a")
    file:close()
    if msgs
      local ok
      ok, msgs = pcall(cjson.decode, msgs)
      if ok and msgs
        return msgs
      end
    end
  end
  return {}
end



function _M.getCacheMsgById(id)
  local list = _M.getCacheMsgs()
  for i = 1, #list
    if list[i]["id"] == id
      return list[i]
    end
  end
  return false
end

function _M.getCacheMsgByPath(path)
  local list = _M.getCacheMsgs()
  for i = 1, #list
    if list[i]["info"] == path
      return list[i]
    end
  end
  return false
end

_M.getCacheMsgByInfo = _M.getCacheMsgByPath


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


function _M.musicInfoDialog(path)
  if not isInit
    initDialog()
    isInit = true
  end
  local msg = _M.getCacheMsgByPath(path)
  view.title.text = msg and msg.title or "Unknown"
  pcall(function()
    Glide.with(activity).load((msg or {}).cover or activity.getLuaDir().."/res/imgs/miku2.png").into(view.cover)
    view.cover.colorFilter=(msg or {}).cover and 0x00000000 or Colors.colorOnSurface
  end)
  view.cover.onLongClick = function()
    local myToast = require "myToast"
    if msg and msg["cover"]
      local path = "/sdcard/Pictures/"..tostring(msg["id"])..".png"
      local LuaUtil = bindClass "com.androlua.LuaUtil"
      LuaUtil.copyDir(msg["cover"], path)
      local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
      MediaScannerConnection.scanFile(activity, {File(path).getAbsolutePath()}, {"image/png"}, nil)
      myToast.toast("封面已经保存好了꒰ *•ɷ•* ꒱\n[File:"..path.."]")
     else
      myToast.toast("貌似没有封面哦")
    end
  end
  local loveManager = require "loveManager"
  view.isLove.text = loveManager.isLoved(path) and "已收藏" or "未收藏"
  view.from.text = "本地文件"
  dialog.show()
end


return _M

