

local Space = luajava.bindClass "android.widget.Space"
local RecyclerView = luajava.bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"


return {
  LinearLayoutCompat,
  layout_width=-1,
  layout_height=-1,
  orientation=1,
  {
    RecyclerView,
    layout_width=-1,
    layout_height=-1,
    layout_weight=1,
    id="nowPlayListRecycler",
  },
  {
    Space,
    layout_height="170dp",
    layout_width=-1,
  },
}


