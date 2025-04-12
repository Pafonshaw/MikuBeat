--主要是为首次进入进行一些配置


--获取软件信息
local appInfo = require "appInfo"
local Glide = luajava.bindClass "com.bumptech.glide.Glide"
local File = luajava.bindClass "java.io.File"
local loadlayout = require "loadlayout2"

--初始化设置
activity.setSharedData("dynamicColor", true) --默认开启动态取色，但安卓12以下只有紫色
activity.setSharedData("dark", false)
activity.setSharedData("light", false) --默认主题跟随系统
activity.setSharedData("startLastPage", true)
activity.setSharedData("startPage", 1) --默认开启记住最后的页面并设置首次启动页为首页
activity.setSharedData("loopOneOrder", false) --默认使用列表循环
activity.setSharedData("dontShowUpdate", false)
activity.setSharedData("sliderUpdateTime", 1000)
activity.setSharedData("moreAnimation", true)
activity.setSharedData("isRecreat", false)
activity.setSharedData("playLastPlay", true)
activity.setSharedData("isDebug", false)
activity.setSharedData("useParsing", false)
activity.setSharedData("musicQuality", "standard")
activity.setSharedData("autoUpdate", true)
activity.setSharedData("clickShowBili", false)
activity.setSharedData("playLastPlay", true)
activity.setSharedData("volume", 0.6)

require "miku" --初始化设置后才可导入

--初始化音乐信息缓存
File(activity.getExternalFilesDir(nil).getPath().."/music/cache/cache/").mkdirs()

--初始化历史记录，收藏，用户添加
if not File(activity.getExternalFilesDir(nil).getPath().."/music/history.json").isFile() io.open(activity.getExternalFilesDir(nil).getPath().."/music/history.json", "w"):write("[]"):close() end
if not File(activity.getExternalFilesDir(nil).getPath().."/music/love.json").isFile() io.open(activity.getExternalFilesDir(nil).getPath().."/music/love.json", "w"):write("[]"):close() end
if not File(activity.getExternalFilesDir(nil).getPath().."/music/history.json").isFile() io.open(activity.getExternalFilesDir(nil).getPath().."/music/userAdd.json", "w"):write("[]"):close() end

activity
.setTitle("欢迎")
.setContentView(loadlayout("layout.welcome")) --取自梅花易排盘 By xiayu

--为页面设置各种信息
fab.setImageResource(MDC_R.drawable.material_ic_keyboard_arrow_right_black_24dp)
Glide.with(this).load(appInfo.icon).into(ivIcon)
tvAppName.setText("欢迎使用 " .. appInfo.name)
tvVersionName.setText("当前版本：".. appInfo.versionName)
tvDeveloper.setText("开发者：" .. appInfo.developer)

local PackageManager = luajava.bindClass "android.content.pm.PackageManager"
local ActivityCompat = luajava.bindClass "androidx.core.app.ActivityCompat"


local permission = "android.permission.WRITE_EXTERNAL_STORAGE" -- 修改或删除SD卡内容的权限
local granted = activity.checkSelfPermission(permission) -- 检查权限是否被授予
if granted == PackageManager.PERMISSION_GRANTED then
  print("已获取存储权限")
 else
  ActivityCompat.requestPermissions(this, {"android.permission.WRITE_EXTERNAL_STORAGE"}, 1) --申请权限
end

--点击fab回到首页并设置非首次进入标识
fab.onClick = function()
  activity.setSharedData("welcome", true)
  activity.newActivity("main").finish()
end


