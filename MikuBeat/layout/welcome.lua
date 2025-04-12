
--欢迎界面布局_取自梅花易排盘 by xiayu

local MaterialToolbar = luajava.bindClass "com.google.android.material.appbar.MaterialToolbar"
local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local CoordinatorLayout = luajava.bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local FloatingActionButton = luajava.bindClass "com.google.android.material.floatingactionbutton.FloatingActionButton"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppBarLayout = luajava.bindClass "com.google.android.material.appbar.AppBarLayout"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"

return {
  CoordinatorLayout,
  layout_width=-1,
  layout_height=-1,
  id="background",
  {
    AppBarLayout,
    backgroundColor=0,
    id="appBar",
    paddingTop=systemStatusBarHeight,
    layout_width=-1,
    transitionName="appBar",
    {
      MaterialToolbar,
      title="欢迎",
      subtitle="欢迎使用MikuBeat",
      layout_scrollFlags=2,
      id="toolbar",
      layout_width=-1,
    },
  },
  {
    LinearLayoutCompat,
    gravity="center",
    layout_width=-1,
    layout_height=-1,
    orientation=1,
    {
      MaterialCardView,
      strokeWidth=0,
      cardBackgroundColor=0,
      {
        AppCompatImageView,
        layout_width="150dp",
        layout_height="150dp",
        id="ivIcon",
      },
    },
    {
      AppCompatTextView,
      textStyle="bold",
      textSize=23,
      id="tvAppName",
      layout_marginTop="25dp",
    },
    {
      AppCompatTextView,
      id="tvVersionName",
      layout_margin="20dp",
    },
    {
      AppCompatTextView,
      id="tvDeveloper",
    },
  },
  {
    FloatingActionButton,
    layout_gravity="bottom|end",
    layout_margin="16dp",
    layout_marginBottom="32dp",
    id="fab",
    maxImageSize="30dp",
  },
}