
--主页布局

local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local RecyclerView = luajava.bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local NestedScrollView = luajava.bindClass "androidx.core.widget.NestedScrollView"
local Space = luajava.bindClass "android.widget.Space"

local Banner = activity.loadDex(activity.getLuaPath("libs/Pager2Banner.dex")).loadClass("com.to.aboomy.pager2banner.Banner")

local LayoutTransition = luajava.bindClass "android.animation.LayoutTransition"

local FileDrawable = require "FileDrawable"
local historyManager = require "historyManager"


return {
  NestedScrollView,
  layout_width=-1,
  layout_height=-1,
  fillViewport=true,
  --backgroundDrawable=FileDrawable("/res/imgs/1735805552232.png"),
  {
    LinearLayoutCompat,
    layout_width=-1,
    layout_height=-1,
    orientation=1,
    layoutTransition=newLayoutTransition(400),
    {
      Banner,
      id="carousel",
      layout_width=-1,
      layout_height="200dp",
      layout_marginTop="16dp",
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth="0dp",
      layout_margin="16dp",
      layout_marginBottom="0dp",
      cardBackgroundColor=Colors.colorSurfaceContainer,--colorSurfaceVariant
      {
        LinearLayoutCompat,
        layout_height=-1,
        layout_width=-1,
        orientation=1,--1垂直，0水平
        layoutTransition=newLayoutTransition(400),
        {
          LinearLayoutCompat,
          layout_width=-1,
          orientation=0,
          id="annouHome",
          onClick=function()
            announcement.visibility = announcement.visibility == 0 and 8 or 0
          end,
          {
            AppCompatImageView,
            colorFilter=Colors.colorOnSurfaceVariant,
            src="res/imgs/announcement.png",
            layout_height="28dp",
            layout_width="28dp",
            layout_gravity="center|left",
            layout_margin="16dp",
          },
          {
            AppCompatTextView,
            text="公告",
            layout_weight=1,
            layout_gravity="center|left",
            textSize="16sp",
            textColor=Colors.colorOnBackground,
          },
          {
            AppCompatImageView,
            colorFilter=Colors.colorOnSurfaceVariant,
            layout_height="20dp",
            layout_width="20dp",
            layout_gravity="center|right",
            src="res/imgs/expand.png",
            layout_margin="16dp",
          },
        },
        {
          AppCompatTextView,
          id="announcement",
          layout_width=-1,
          visibility=8,
          layout_margin="16dp",
          layout_marginTop="0dp",
          text="announcement",
          textSize="16sp",
          textColor=Colors.colorOnBackground,
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth="0dp",
      layout_margin="16dp",
      layout_marginBottom="0dp",
      cardBackgroundColor=Colors.colorSurfaceContainer,--colorSurfaceVariant
      {
        LinearLayoutCompat,
        layout_width=-1,
        orientation=0,
        id="totalHome",
        {
          AppCompatImageView,
          colorFilter=Colors.colorOnSurfaceVariant,
          src="res/imgs/music.png",
          layout_height="28dp",
          layout_width="28dp",
          layout_gravity="center|left",
          layout_margin="16dp",
        },
        {
          AppCompatTextView,
          text="全部音乐",
          layout_weight=1,
          layout_gravity="center|left",
          textSize="16sp",
          textColor=Colors.colorOnBackground,
        },
        {
          AppCompatImageView,
          colorFilter=Colors.colorOnSurfaceVariant,
          layout_height="20dp",
          layout_width="20dp",
          layout_gravity="center|right",
          src="res/imgs/go.png",
          layout_margin="16dp",
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth="0dp",
      layout_margin="16dp",
      layout_marginBottom="0dp",
      cardBackgroundColor=Colors.colorSurfaceContainer,--colorSurfaceVariant
      {
        LinearLayoutCompat,
        layout_width=-1,
        orientation=0,
        id="playlistHome",
        {
          AppCompatImageView,
          colorFilter=Colors.colorOnSurfaceVariant,
          src="res/imgs/playlist.png",
          layout_height="28dp",
          layout_width="28dp",
          layout_gravity="center|left",
          layout_margin="16dp",
        },
        {
          AppCompatTextView,
          text="播放列表",
          layout_weight=1,
          layout_gravity="center|left",
          textSize="16sp",
          textColor=Colors.colorOnBackground,
        },
        {
          AppCompatImageView,
          colorFilter=Colors.colorOnSurfaceVariant,
          layout_height="20dp",
          layout_width="20dp",
          layout_gravity="center|right",
          src="res/imgs/go.png",
          layout_margin="16dp",
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth="0dp",
      layout_margin="16dp",
      cardBackgroundColor=Colors.colorSurfaceContainer,--colorSurfaceVariant
      {
        LinearLayoutCompat,
        layout_height=-1,
        layout_width=-1,
        orientation=1,--1垂直，0水平
        layoutTransition=newLayoutTransition(400),
        {
          LinearLayoutCompat,
          layout_width=-1,
          orientation=0,
          id="openHistoryOfHome",
          --backgroundColor=0xFF000000,--test
          onClick=function()
            if #historyManager.getHistory() == 0
              local myToast = require "myToast"
              myToast.toast("暂无任何记录，快去听歌吧(๑❛ᴗ❛๑)")
             else
              historyOfHome.visibility = historyOfHome.visibility == 0 and 8 or 0
            end
          end,
          {
            AppCompatImageView,
            colorFilter=Colors.colorOnSurfaceVariant,
            src="res/imgs/history.png",
            layout_height="28dp",
            layout_width="28dp",
            layout_gravity="center|left",
            layout_margin="16dp",
          },
          {
            AppCompatTextView,
            text="播放历史",
            layout_weight=1,
            layout_gravity="center|left",
            textSize="16sp",
            textColor=Colors.colorOnBackground,
          },
          {
            AppCompatImageView,
            colorFilter=Colors.colorOnSurfaceVariant,
            layout_height="20dp",
            layout_width="20dp",
            layout_gravity="center|right",
            src="res/imgs/expand.png",
            layout_margin="16dp",
          },
        },
        {
          RecyclerView,
          id="historyOfHome",
          layout_width=-1,
          visibility=8,
          layout_height=#historyManager.getHistory() < 6 and -2 or "500dp",
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



