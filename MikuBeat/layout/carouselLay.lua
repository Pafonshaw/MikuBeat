
--轮播图布局

local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"

return {
  LinearLayoutCompat,
  layout_height=-1,
  layout_width=-1,
  {
    MaterialCardView,
    layout_height=-1,
    layout_width=-1,
    {
      AppCompatImageView,
      layout_height=-1,
      layout_width=-1,
      id="carouselImg",
      scaleType="center",
      layout_gravity="center",
    },
  },
}

