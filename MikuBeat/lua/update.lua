
local bindClass = luajava.bindClass
local require = require
local activity =activity

local MaterialAlertDialogBuilder = bindClass "com.google.android.material.dialog.MaterialAlertDialogBuilder"
local cjson = require "cjson"
local myToast = require "myToast"
local File = bindClass "java.io.File"
local Uri = bindClass "android.net.Uri"
local Intent = bindClass "android.content.Intent"
local Build = bindClass "android.os.Build"

local _M = {}


local function installApkBySystem(file_path)
  local MimeTypeMap = bindClass "android.webkit.MimeTypeMap"
  local FileName=tostring(File(file_path).Name)
  local ExtensionName=FileName:match(".+%.(%w+)$")
  local Mime=MimeTypeMap.getSingleton().getMimeTypeFromExtension(ExtensionName)
  if Mime then
    local intent = Intent();
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.setAction(Intent.ACTION_VIEW);
    intent.setDataAndType(Uri.fromFile(File(file_path)), Mime);
    activity.startActivity(intent);
   else
    myToast.toast("找不到可以用来安装文件的程序，可加群获取自行安装")
  end
end

local function installApk(apk_path)
  if Build.VERSION.SDK_INT <=23 then
    installApkBySystem(apk_path)
   else
    activity.installApk(apk_path)
  end
end


local function checkPermission()
  if not activity.getPackageManager().canRequestPackageInstalls() and 0==this.checkSelfPermission("android.permission.READ_EXTERNAL_STORAGE") then--存储权限检测
    myToast.toast("请先授予安装权限")
    local Settings = bindClass "android.provider.Settings"
    activity.startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,Uri.parse("package:"..activity.getPackageName())))
    activity.requestPermissions({"android.permission.READ_EXTERNAL_STORAGE","android.permission.INTERNET"},1)
   else
    return true
  end
end


function _M.joinQGroup()
  xpcall(function()
    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=912150197&card_type=group&source=qrcode")))
  end, function()
    copyText("912150197")
    myToast.toast("跳转QQ异常，已复制群号")
  end)
end



local function updateDialogRelease(update)
  local updateText = update.release.update or "发现新版本！"
  local mastUpdate = update.release.mast
  local link = update.release.link
  local dialog = MaterialAlertDialogBuilder(this)
  .setTitle("发现新版本_"..update.release.version)
  .setMessage(updateText)
  .setCancelable(not mastUpdate)
  .setPositiveButton("更新", function()
    if checkPermission()
      if link
        myToast.toast("后台下载中")
        Http.download(link, activity.getExternalFilesDir(nil).getPath().."/update.apk", function(code)
          if code == 200
            if checkPermission() and not pcall(installApk, activity.getExternalFilesDir(nil).getPath().."/update.apk")
              myToast.toast("安装失败，可加群下载自行安装")
            end
           else
            myToast.toast("下载失败，可自行加群下载")
          end
        end)
       else
        myToast.toast("无下载链接，可加群获取")
      end
    end
  end)
  if not mastUpdate dialog.setNeutralButton("取消", nil) end
  dialog.show()
end


local function updateDialogBeta(update)
  local updateText = update.beta.update or "发现新版本！"
  local mastUpdate = update.beta.mast
  local dialog = MaterialAlertDialogBuilder(this)
  .setTitle("发现新版本_"..update.beta.version)
  .setMessage(updateText)
  .setCancelable(not mastUpdate)
  .setPositiveButton("更新", _M.joinQGroup)
  if not mastUpdate dialog.setNeutralButton("取消", nil) end
  dialog.show()
end

function _M.checkUpdate(dontToast)
  Http.get("http://8.218.86.120/main/api/document/passage.php?fxwzoxawzmpjzb",function(code, content)
    if code == 200
      local version = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName --当前版本
      --version = "0.1Alpha" -- 测试用，发布必须注释
      local ok, update = pcall(cjson.decode, content) -- 反序列化json
      if not ok
        if not dontToast myToast.toast("请求异常") end
        return
      end
      if string.sub(version, 4) == "Release"
        || string.sub((update.beta or {}).version or "0123456789", 4) == "Release" -- 当前版本或总最新版为正式版，走正式版更新逻辑
        if version ~= ((update.release or {}).version or version) -- 检查版本信息
          updateDialogRelease(update) -- 更新
        end
       elseif version ~= ((update.beta or {}).version or version) -- 当前版本为测试版且总最新版不为正式版，走测试版更新逻辑
        updateDialogBeta(update)
       elseif not dontToast
        myToast.toast("当前已经是最新版了")
      end
     elseif not dontToast
      myToast.toast("请求异常")
    end
  end)
end



function _M.getAnnouncement(func)
  Http.get("http://8.218.86.120/main/api/bulletin/bulletin.php?admin=271607916",function(code, content)
    if code ~= 200--请求异常提示用户
      print("请求异常")
     else
      local ok, announcementMsg = pcall(cjson.decode, content)
      if ok and (announcementMsg or {}).code == 1
        func(announcementMsg.data)
       else
        func(false)
      end
    end
  end)
end


--[[
function _M.upAndAnnou(callback)
  Http.get("https://sharechain.qq.com/f54f0f0898f1bbaa94659a9b834bd72e",function(code, content)
    if code ~= 200 --请求异常提示用户
      print("请求异常")
     else
      local edition = string.match(content, "【版本】【(.-)】")
      local announcementMsg = string.match(content, "【公告】【(.-)】")
      if announcementMsg and announcementMsg ~= ""
        callback(announcementMsg)
       else
        callback("获取失败")
      end
      if edition and edition ~= ""
        if edition ~= activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName
          local mastUpdate = string.match(content, "【强制更新】【(.-)】") == "是"
          local updateText = string.match(content, "【更新文案】【(.-)】")
          local MaterialAlertDialogBuilder = luajava.bindClass "com.google.android.material.dialog.MaterialAlertDialogBuilder"
          local dialog = MaterialAlertDialogBuilder(this)
          .setTitle("发现新版本")
          .setMessage(updateText)
          .setCancelable(not mastUpdate)
          .setPositiveButton("更新", _M.joinQQGroup)
          if not mastUpdate dialog.setNeutralButton("取消", nil) end
          dialog.show()
        end
       else
        print("最新版本信息获取失败")
      end
    end
  end)
end
]]


return _M

