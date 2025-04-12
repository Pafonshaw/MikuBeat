
--音乐卡片_音乐界面

local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local MarqueeTextView = activity.loadDex(activity.getLuaPath("libs/MarqueeTextView.dex")).loadClass("com.xiayu372.widget.MarqueeTextView")

return {
  LinearLayoutCompat,
  layout_width=-1,
  id="cardRootView",
  {
    MaterialCardView,
    layout_width=-1,
    strokeWidth=0,
    clickable=true,
    id="cardToChooseMusic",
    {
      LinearLayoutCompat,
      --id="cardInside",
      layout_width=-1,
      layout_height=-2,
      orientation=0,--水平
      gravity="center",
      padding="16dp",
      {
        MaterialCardView,
        layout_height=-2,
        layout_width=-2,
        strokeWidth=0,
        {
          AppCompatImageView,
          id="cardMusicPicture",
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
        layout_marginStart="16dp",
        layout_marginEnd="16dp",
        layout_gravity="center|left",
        {
          MarqueeTextView,
          text="MikuBeat~Music",
          id="cardMusicName",
          textSize="16sp",
          textColor=Colors.colorOnBackground,
        },
        {
          AppCompatTextView,
          text="MikuBeat~Artist",
          id="cardMusicArtist",
          textSize="12sp",
          singleLine=true,
          maxLines=1,
          ellipsize="end",
          layout_marginTop="4dp",
          textColor=Colors.colorOutline,
        },
      },
      {
        AppCompatImageView,
        layout_gravity="center",
        id="cardLoveImg",
        layout_width="24dp",
        layout_height="24dp",
        colorFilter=Colors.colorOnSurface,
        layout_marginEnd="16dp",
      },
      {
        AppCompatImageView,
        layout_gravity="center",
        id="cardPopMenu",
        layout_width="24dp",
        layout_height="24dp",
        src="res/imgs/pop.png",
        colorFilter=Colors.colorOnSurface,
      },
    },
  },
}
