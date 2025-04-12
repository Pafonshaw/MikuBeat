
--音乐界面布局

local RecyclerView = luajava.bindClass "androidx.recyclerview.widget.RecyclerView"
local ViewPager = luajava.bindClass "androidx.viewpager.widget.ViewPager"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local TabLayout = luajava.bindClass "com.google.android.material.tabs.TabLayout"
local RelativeLayout = luajava.bindClass "android.widget.RelativeLayout"
local Space = luajava.bindClass "android.widget.Space"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"

return {
  LinearLayoutCompat,
  orientation=1,
  layout_width="fill",
  layout_height="fill",
  {
    TabLayout,
    id="mtab",
    layout_width="fill",
    layout_height="wrap",
  },
  {
    ViewPager,
    id="cvpg",
    layout_width="fill",
    layout_height="fill",
    layout_weight=1,
    pagesWithTitle={
      {
        {
          LinearLayoutCompat,
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          {
            RecyclerView,
            layout_width=-1,
            layout_height=-1,
            id="musicMusicList",
            layout_weight=1,
          },
        },
        {
          LinearLayoutCompat,
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          {
            RecyclerView,
            layout_width=-1,
            layout_height=-1,
            id="musicUserAddList",
            layout_weight=1,
          },
        },
        {
          LinearLayoutCompat,
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          {
            RecyclerView,
            layout_width=-1,
            layout_height=-1,
            id="musicLocalList",
            layout_weight=1,
          },
        },
        {
          LinearLayoutCompat,
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          {
            RecyclerView,
            layout_width=-1,
            layout_height=-1,
            id="musicLoveList",
            layout_weight=1,
          },
        },
      },
      {
        "音乐列表",
        "添加曲目",
        "本地歌曲",
        "我的收藏",
      },
    },
  },
  {
    Space,
    layout_width=-1,
    layout_height="170dp",
  },
}