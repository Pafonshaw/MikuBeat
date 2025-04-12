--进行一些全局配置

--[[
DO:
+ 导入import, loadlayout, MDC_R
+ 设置主题
+ 设置状态栏沉浸
+ 定义状态栏高度函数
--]]

--可点击标识
canClick = true

require "import"

loadlayout = require "loadlayout2" --loadlayout改进版 By xiayu
--全局md3资源类
MDC_R = luajava.bindClass "com.google.android.material.R"

--全局颜色资源
Colors = require "Colors"

local Build = luajava.bindClass "android.os.Build"
--local WindowManager = luajava.bindClass "android.view.WindowManager"

--获取主题设置
local light = this.getSharedData("light")
local dark = this.getSharedData("dark")
local dynamicColor = this.getSharedData("dynamicColor")

--设置主题
this.setTheme(MDC_R.style["Theme_Material3_" .. (dynamicColor and "DynamicColors_" or "") .. (light and "Light" or dark and "Dark" or "DayNight")])
this.getSupportActionBar().hide() --隐藏bar

--状态栏沉浸
--local EdgeToEdgeUtils = luajava.bindClass "com.google.android.material.internal.EdgeToEdgeUtils"
--EdgeToEdgeUtils.applyEdgeToEdge(activity.getWindow(), true)
--activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
--activity.getWindow().getAttributes().layoutInDisplayCutoutMode=1
local WindowManager = luajava.bindClass "android.view.WindowManager"
local View = luajava.bindClass "android.view.View"

local window = activity.getWindow()

window
.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
--.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS).setStatusBarColor(Colors.colorBackground)
.setNavigationBarColor(Colors.colorBackground)

--沉浸状态栏
if Build.VERSION.SDK_INT >= 21 then
  window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
  window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
  | View.SYSTEM_UI_FLAG_LAYOUT_STABLE |View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
  window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
  window.setStatusBarColor(Colors.colorBackground);
  --window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);--影响popup，使得显示超出屏幕，故注释掉
 else
  window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
  window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
end


--设置状态栏图标颜色函数
local function setSystemBarIconColor(darkFlag)
  if Build.VERSION.SDK_INT >= 21 then
    window = activity.getWindow()
    local flags
    if darkFlag
      flags = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE -- 设置状态栏图标为浅色
     else
      flags = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR -- 设置状态栏图标为深色
    end
    window.getDecorView().setSystemUiVisibility(flags)
  end
end

local Context = luajava.bindClass "android.content.Context"
local UiModeManager = luajava.bindClass "android.app.UiModeManager"
local Configuration = luajava.bindClass "android.content.res.Configuration"

--根据模式设置状态栏图标颜色
local uiModeManager = activity.getSystemService(Context.UI_MODE_SERVICE)
local currentModeType = uiModeManager.getCurrentModeType()
if light
  setSystemBarIconColor()
 elseif dark
  setSystemBarIconColor(true)
 else
  if currentModeType == UiModeManager.MODE_NIGHT_YES then
    setSystemBarIconColor(true)
   elseif currentModeType == UiModeManager.MODE_NIGHT_NO then
    setSystemBarIconColor()
   else
    print("无法确定夜间模式状态")
  end
end

--状态栏高度全局变量
systemStatusBarHeight = (function()
  if Build.VERSION.SDK_INT >= 19 then
    local resourceId = activity.getResources().getIdentifier("status_bar_height", "dimen", "android")
    return activity.getResources().getDimensionPixelSize(resourceId)
   else
    return 0
  end
end)()


local LayoutTransition = luajava.bindClass "android.animation.LayoutTransition"

--布局动画全局函数
function newLayoutTransition(time)
  return LayoutTransition()
  .enableTransitionType(LayoutTransition.CHANGING)
  .setDuration(time or 200)
end


--[[
local function px2dp(pxValue)
  local scale = activity.getResources().getDisplayMetrics().density
  return (pxValue + 0.5) / scale
end

function 导航栏高度()
  if Build.VERSION.SDK_INT >= 19 then
    local resourceId = activity.getResources().getIdentifier("navigation_bar_height", "dimen", "android")
    return px2dp(activity.getResources().getDimensionPixelSize(resourceId))
   else
    return 0
  end
end]]

function string:html()
    local entities = {
        ["&nbsp;"] = " ",
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&amp;"] = "&",
        ["&quot;"] = '"',
        ["&apos;"] = "'",
        ["&copy;"] = "©",
        ["&reg;"] = "®",
        ["&trade;"] = "™",
        ["&euro;"] = "€",
        ["&cent;"] = "￠",
        ["&sect;"] = "§",
        ["&times;"] = "×",
        ["&divide;"] = "÷",
        -- 添加更多实体...
    }

    for entity, char in pairs(entities) do
        self = self:gsub(entity, char)
    end

    return self
end

local ClipData = luajava.bindClass "android.content.ClipData"
function copyText(str,label)
  activity.getSystemService(Context.CLIPBOARD_SERVICE).setPrimaryClip(ClipData.newPlainText(label or "Label", str))
end
