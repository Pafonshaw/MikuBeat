
local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local Space = bindClass "android.widget.Space"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
local Slider = bindClass "com.google.android.material.slider.Slider"

return {
  NestedScrollView,
  layout_height=-1,
  layout_width=-1,
  fillViewport=true,
  id="settingScroll",
  {
    LinearLayoutCompat,
    layout_width=-1,
    layout_height=-1,
    orientation=1,
    layoutTransition=newLayoutTransition(400),
    {
      AppCompatTextView,
      text="设置",
      textSize="20sp",
      textColor=Colors.colorPrimary,
      layout_margin="16dp",
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/volume.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="APP音量",
            textColor=Colors.colorOnBackground,
            textSize="16sp",
            layout_gravity="center",
          },
          {
            Slider,
            ValueTo=100,
            trackHeight=20,
            Value=tonumber(activity.getSharedData("volume") or "0.6")*100,
            labelFormatter=function(v) return tostring(tointeger(v)) end,
            id="appVolume",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, daynightPopLocation)
        pop.menu.add("亮色主题").onMenuItemClick=function()
          activity.setSharedData("light", true)
          daynightPopLocation.text = "亮色主题"
        end
        pop.menu.add("暗色主题").onMenuItemClick=function()
          activity.setSharedData("light", false)
          activity.setSharedData("dark", true)
          daynightPopLocation.text = "暗色主题"
        end
        pop.menu.add("跟随系统").onMenuItemClick=function()
          activity.setSharedData("light", false)
          activity.setSharedData("dark", false)
          daynightPopLocation.text = "跟随系统"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/daynight.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="主题设置",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("light") and "亮色主题" or activity.getSharedData("dark") and "暗色主题" or "跟随系统",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="daynightPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, dynamicPopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("dynamicColor", true)
          dynamicPopLocation.text = "已开启(安卓12以下仅紫色)"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("dynamicColor", false)
          dynamicPopLocation.text = "未开启(仅支持安卓12及以上)"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/dynamic.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="动态取色",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("dynamicColor") and "已开启(安卓12以下仅紫色)" or "未开启(仅支持安卓12及以上)",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="dynamicPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, autoUpdatePopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("autoUpdate", true)
          autoUpdatePopLocation.text = "已开启"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("autoUpdate", false)
          autoUpdatePopLocation.text = "未开启"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/update.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="自动检测更新",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=(activity.getSharedData("autoUpdate") or activity.getSharedData("autoUpdate") == nil)and "已开启" or "未开启",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="autoUpdatePopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, musicLinePopLocation)
        pop.menu.add("官方接口").onMenuItemClick=function()
          activity.setSharedData("useParsing", false)
          musicLinePopLocation.text = "官方线路"
          musicQualitySetting.visibility=8
        end
        pop.menu.add("解析接口").onMenuItemClick=function()
          activity.setSharedData("useParsing", true)
          musicLinePopLocation.text = "解析线路"
          musicQualitySetting.visibility=0
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/line.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="WY音乐线路",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("useParsing") and "解析线路" or "官方线路",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="musicLinePopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      id="musicQualitySetting",
      visibility=activity.getSharedData("useParsing") and 0 or 8,
      onClick=function()
        local pop = PopupMenu(activity, qualityPopLocation)
        pop.menu.add("标准音质").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "standard")
          qualityPopLocation.text = "标准音质(standard)"
        end
        pop.menu.add("极高音质").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "exhigh")
          qualityPopLocation.text = "极高音质(exhigh)"
        end
        pop.menu.add("无损音质").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "lossless")
          qualityPopLocation.text = "无损音质(lossless)"
        end
        pop.menu.add("Hi-Res音质").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "hires")
          qualityPopLocation.text = "Hi-Res音质(hires)"
        end
        pop.menu.add("高清环绕声").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "jyeffect")
          qualityPopLocation.text = "高清环绕声(jyeffect)"
        end
        pop.menu.add("沉浸环绕声").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "sky")
          qualityPopLocation.text = "沉浸环绕声(sky)"
        end
        pop.menu.add("超清母带").onMenuItemClick=function()
          activity.setSharedData("musicQuality", "jymaster")
          qualityPopLocation.text = "超清母带(jymaster)"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/musicQuality.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="解析线路音质",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("musicQuality") or "standard",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="qualityPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, refreshPopLocation)
        pop.menu.add("1000").onMenuItemClick=function()
          activity.setSharedData("sliderUpdateTime", 1000)
          refreshPopLocation.text = "1000毫秒"
        end
        pop.menu.add("500").onMenuItemClick=function()
          activity.setSharedData("sliderUpdateTime", 500)
          refreshPopLocation.text = "500毫秒"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/interval.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="播放进度刷新间隔",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=tostring(activity.getSharedData("sliderUpdateTime")).."毫秒",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="refreshPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, startPagePopLocation)
        pop.menu.add("首页").onMenuItemClick=function()
          activity.setSharedData("startLastPage", false)
          activity.setSharedData("startPage", 1)
          startPagePopLocation.text = "首页"
        end
        pop.menu.add("音乐").onMenuItemClick=function()
          activity.setSharedData("startLastPage", false)
          activity.setSharedData("startPage", 2)
          startPagePopLocation.text = "音乐"
        end
        pop.menu.add("更多").onMenuItemClick=function()
          activity.setSharedData("startLastPage", false)
          activity.setSharedData("startPage", 3)
          startPagePopLocation.text = "更多"
        end
        pop.menu.add("上次关闭").onMenuItemClick=function()
          activity.setSharedData("startLastPage", true)
          activity.setSharedData("startPage", 3)
          startPagePopLocation.text = "上次关闭"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/startPage.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="默认启动页",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("startLastPage") and "上次关闭" or activity.getSharedData("startPage") == 1 and "首页" or activity.getSharedData("startPage") == 2 and "音乐" or "更多",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="startPagePopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, autoPlayPopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("playLastPlay", true)
          autoPlayPopLocation.text = "开启"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("playLastPlay", false)
          activity.setSharedData("lastPlayTime", 0)
          autoPlayPopLocation.text = "关闭"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/autoPlay.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="启动自动播放",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("playLastPlay") == false and "关闭" or "开启",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="autoPlayPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, moreAnimationPopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("moreAnimation", true)
          moreAnimationPopLocation.text = "开启"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("moreAnimation", false)
          moreAnimationPopLocation.text = "关闭"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/moreAnimation.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="更多动画",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("moreAnimation") and "开启" or "关闭",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="moreAnimationPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, gradientPlayCardPopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("gradientPlayCard", true)
          gradientPlayCardPopLocation.text = "开启"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("gradientPlayCard", false)
          gradientPlayCardPopLocation.text = "关闭"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/gradient.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="渐变色播放卡片",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=(activity.getSharedData("gradientPlayCard") or activity.getSharedData("gradientPlayCard") == nil) and "开启" or "关闭",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="gradientPlayCardPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local MaterialAlertDialogBuilder = luajava.bindClass "com.google.android.material.dialog.MaterialAlertDialogBuilder"
        local dialog = MaterialAlertDialogBuilder(this)
        .setTitle("确认清理缓存")
        .setMessage("要让我忘掉所有学会的歌吗？下次再学习，会继续吃掉你的流量哦(ó﹏ò｡) ")
        .setCancelable(true)
        .setPositiveButton("确定", function()
          local LuaUtil = luajava.bindClass "com.androlua.LuaUtil"
          local File = luajava.bindClass "java.io.File"
          local myToast = require "myToast"
          xpcall(function()
            LuaUtil.rmDir(File(activity.getExternalFilesDir(nil).getPath().."/music/cache/"))
            LuaUtil.rmDir(File(activity.getExternalFilesDir(nil).getPath().."/music/cover/"))
            File(activity.getExternalFilesDir(nil).getPath().."/music/local.json").delete()
            File(activity.getExternalFilesDir(nil).getPath().."/music/cache/cache/").mkdirs()
            File(activity.getExternalFilesDir(nil).getPath().."/music/cover/").mkdirs()
            myToast.toast("对MikuBeat施展了催眠术，忘掉了全部歌曲")
            end, function()
            myToast.toast("删除过程中出现意外")
          end)
        end)
        .setNeutralButton("取消", nil)
        .show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/clear.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="清空缓存",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text="清空缓存后，再次播放将继续消耗流量",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="clearPopLocation",
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth=0,
      radius=0,
      onClick=function()
        local pop = PopupMenu(activity, debugPopLocation)
        pop.menu.add("开启").onMenuItemClick=function()
          activity.setSharedData("isDebug", true)
          debugPopLocation.text = "开启"
        end
        pop.menu.add("关闭").onMenuItemClick=function()
          activity.setSharedData("isDebug", false)
          debugPopLocation.text = "关闭"
        end
        pop.show()
      end,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        padding="5dp",
        {
          AppCompatImageView,
          src="res/imgs/debug.png",
          layout_width="30dp",
          layout_height="30dp",
          colorFilter=Colors.colorPrimary,
          layout_margin="16dp",
        },
        {
          LinearLayoutCompat,
          layout_height=-1,
          layout_width=-2,
          orientation=1,
          layout_margin="10dp",
          layout_marginLeft=0,
          {
            AppCompatTextView,
            text="Debug模式",
            layout_weight=1,
            textColor=Colors.colorOnBackground,
            textSize="16sp",
          },
          {
            AppCompatTextView,
            text=activity.getSharedData("isDebug") and "开启" or "关闭",
            layout_weight=1,
            textColor=Colors.colorOutline,
            textSize="13sp",
            id="debugPopLocation",
          },
        },
      },
    },
    {
      Space,
      layout_width=-1,
      layout_height="170dp",
    },
  },
}
