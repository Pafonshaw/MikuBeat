
--整体布局架构

local FragmentContainerView = luajava.bindClass "androidx.fragment.app.FragmentContainerView"
local MaterialToolbar = luajava.bindClass "com.google.android.material.appbar.MaterialToolbar"
local AppBarLayout = luajava.bindClass "com.google.android.material.appbar.AppBarLayout"
local BottomNavigationView = luajava.bindClass "com.google.android.material.bottomnavigation.BottomNavigationView"
local CoordinatorLayout = luajava.bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local FloatingActionButton = luajava.bindClass "com.google.android.material.floatingactionbutton.FloatingActionButton"

local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local MarqueeTextView = activity.loadDex(activity.getLuaPath("libs/MarqueeTextView.dex")).loadClass("com.xiayu372.widget.MarqueeTextView")
local Slider = luajava.bindClass "com.google.android.material.slider.Slider"
local ColorStateList = luajava.bindClass "android.content.res.ColorStateList"


--local GradientDrawable = luajava.bindClass "android.graphics.drawable.GradientDrawable"
--local LuaDrawable = luajava.bindClass "com.androlua.LuaDrawable"

return {
  CoordinatorLayout,
  layout_width=-1,
  layout_height=-1,
  id="mContent",
  {
    AppBarLayout,
    layout_height=-2,
    layout_width=-1,
    id="appBar",
    paddingTop=systemStatusBarHeight,
    backgroundColor=Colors.colorBackground,
    {
      MaterialToolbar,
      layout_height=-2,
      layout_width=-1,
      layout_scrollFlags="snap",
      id="mToolbar",
      title="MikuBeat",
      subtitle="米库打油~",
    },
  },
  {
    FragmentContainerView,
    id="fragmentContainer",
    layout_behavior="appbar_scrolling_view_behavior",
    layout_width=-1,
    layout_height=-1,
  },
  {
    BottomNavigationView,
    id="bottombar",
    layout_gravity="bottom",
    layout_width=-1,
    layout_height=-2,
    labelVisibilityMode=0,
    --layout_height="80dp",
  },
  {
    FloatingActionButton,
    src="res/imgs/add.png",
    layout_gravity="bottom|end",
    layout_marginRight="16dp",
    layout_marginBottom="180dp",
    id="add",
  },
  {
    FloatingActionButton,
    src="res/imgs/reload.png",
    layout_gravity="bottom|end",
    layout_marginRight="16dp",
    layout_marginBottom="180dp",
    maxImageSize="28dp",
    --translationZ="0dp",
    id="usedNow",
    visibility=8,
    onClick=function()
      activity.setSharedData("isRecreat", true)
      activity.recreate()
    end
  },
  {
    LinearLayoutCompat,
    id="fiilInScreen",
    layout_marginBottom="80dp",
    layout_gravity="bottom",
    layout_width=-1,
    layout_height="90dp",
    translationZ="6dp",
    layoutTransition=newLayoutTransition(400),
    {
      MaterialCardView,
      id="fiilInScreenCard",
      layout_margin="3dp",
      layout_marginLeft="6dp",
      layout_marginRight="6dp",
      layout_width=-1,
      strokeWidth=0,
      clickable=true,
      cardBackgroundColor=Colors.colorSurfaceVariant-0x000a0a0a,
      radius="25dp",
      {
        LinearLayoutCompat,
        id="fillInCardLinear",
        layout_width=-1,
        layout_height=-2,
        orientation=0,--水平
        gravity="center",
        padding="16dp",
        clickable=false,
        layoutTransition=newLayoutTransition(400),
        --[[
        backgroundDrawable=LuaDrawable(function(canvas, paint, drawable)
          paint.setAntiAlias(true)
          local w = canvas.getWidth()
          local h = canvas.getHeight()
          canvas.drawCircle(w/2, h/2, h/2, paint)
        end),
        --]]
        {
          MaterialCardView,
          id="playerCardMusicImgCard",
          layout_height=-2,
          layout_width=-2,
          strokeWidth=0,
          {
            AppCompatImageView,
            id="playerCardMusicImg",
            layout_width="52dp",
            layout_height="52dp",
          },
        },
        {
          LinearLayoutCompat,
          layout_height=-2,
          layout_width=-2,
          layout_weight=1,
          orientation=1,
          layout_marginLeft="16dp",
          layout_marginRight="16dp",
          layout_gravity="center|left",
          id="playerCardMsgs",
          layoutTransition=newLayoutTransition(400),
          {
            MarqueeTextView,
            text="MikuBeat~Music",
            id="playerCardName",
            textSize="16sp",
            textColor=Colors.colorOnBackground,
          },
          {
            AppCompatTextView,
            text="MikuBeat~Artist",
            id="playerCardArtist",
            textSize="12sp",
            singleLine=true,
            maxLines=1,
            ellipsize="end",
            layout_marginTop="4dp",
            textColor=Colors.colorOutline,
          },
        },
        {--拖动进度条和歌曲时间，初始设visibility为8
          LinearLayoutCompat,
          layout_height=-2,
          layout_width=-2,
          orientation=1,
          layout_gravity="center",
          id="playerCardDragBarLine",
          visibility=8,
          layoutTransition=newLayoutTransition(400),
          {
            Slider,
            LabelBehavior=1,
            layout_weight=1,
            layout_width="90%w",
            --trackHeight="15dp",
            --thumbRadius="10dp",
            layout_height="20dp",
            layout_gravity="center",
            id="playerCardDragBar",
            TickInactiveTintList=ColorStateList.valueOf(Colors.colorSurfaceVariant),
          },
          {
            LinearLayoutCompat,
            orientation=0,
            layout_width="90%w",
            gravity="center",
            layout_height="35dp",
            layoutTransition=newLayoutTransition(400),
            {
              AppCompatTextView,
              layout_width=-2,
              text="00:00",
              textSize="12sp",
              layout_marginLeft='10dp',
              layout_height="20dp",
              id="playerCardMusicCurrentTime",
            },
            {
              LinearLayoutCompat,
              orientation=0,
              layout_weight=1,
              layout_width=-1,
              layout_height="20dp",
            },
            {
              AppCompatTextView,
              layout_width=-2,
              text="01:39",
              textSize="12sp",
              layout_marginRight='10dp',
              layout_height="20dp",
              id="playerCardMusicEndTime",
            },
          },
        },
        {
          LinearLayoutCompat,
          layout_width=-2,
          layout_height=-2,
          layout_gravity="center",
          id="playerCardItems",
          layoutTransition=newLayoutTransition(400),
          {
            AppCompatImageView,
            layout_gravity="center",
            layout_width="35dp",
            layout_height="35dp",
            layout_marginRight="16dp",
            colorFilter=Colors.colorOnSurface,
            visibility=8,
            id="playerCardLove",
          },
          {
            AppCompatImageView,
            layout_gravity="center",
            id="playerCardPrevious",
            layout_width="24dp",
            layout_height="24dp",
            colorFilter=Colors.colorOnSurface,
            layout_marginRight="16dp",
          },
          {
            AppCompatImageView,
            layout_gravity="center",
            id="playerCardPlay",
            layout_width="24dp",
            layout_height="24dp",
            colorFilter=Colors.colorOnSurface,
            layout_marginRight="16dp",
          },
          {
            AppCompatImageView,
            layout_gravity="center",
            id="playerCardNext",
            layout_width="24dp",
            layout_height="24dp",
            colorFilter=Colors.colorOnSurface,
          },
          {
            AppCompatImageView,
            layout_gravity="center",
            layout_width="35dp",
            layout_height="35dp",
            layout_marginLeft="16dp",
            colorFilter=Colors.colorOnSurface,
            visibility=8,
            id="playerCardOrder",
          },
        },
      },
    },
  },
}
