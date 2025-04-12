
local Space = luajava.bindClass "android.widget.Space"
local ProgressBar = luajava.bindClass "android.widget.ProgressBar"
local RelativeLayout = luajava.bindClass "android.widget.RelativeLayout"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local TextInputLayout = luajava.bindClass "com.google.android.material.textfield.TextInputLayout"
local ColorStateList = luajava.bindClass "android.content.res.ColorStateList"
local TextInputEditText = luajava.bindClass "com.google.android.material.textfield.TextInputEditText"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local ChipGroup = luajava.bindClass "com.google.android.material.chip.ChipGroup"
local RecyclerView = luajava.bindClass "androidx.recyclerview.widget.RecyclerView"
local Chip = luajava.bindClass "com.google.android.material.chip.Chip"
local MaterialButton = luajava.bindClass "com.google.android.material.button.MaterialButton"

local function dp2px(dpValue)
  local scale = activity.getResources().getDisplayMetrics().density;
  return dpValue * scale + 0.5
end


return {
  RelativeLayout,
  layout_height=-1,
  layout_width=-1,
  {
    LinearLayoutCompat,
    layout_width=-1,
    layout_height=-1,
    orientation=1,
    layoutTransition=newLayoutTransition(400),
    {
      LinearLayoutCompat,
      layout_width=-1,
      layout_height=-2,
      {
        TextInputLayout,
        layout_height=-2,
        layout_width="10dp",
        layout_weight=1,
        layout_margin="10dp",
        boxStrokeColor=Colors.colorSurfaceVariant,
        layout_gravity="center",
        boxCornerRadii = {dp2px(25),dp2px(25),dp2px(25),dp2px(25)},
        hint="搜索",
        hintTextColor = ColorStateList.valueOf(Colors.colorOnBackground),
        boxBackgroundMode=TextInputLayout.BOX_BACKGROUND_OUTLINE,
        startIconDrawable=MDC_R.drawable.ic_search_black_24,
        {
          TextInputEditText,
          id="search",
          textColor=Colors.colorOnBackground,
          maxLines=1,
          singleLine=true,
          --imeOptions="actionSearch",
          layout_height=-2,
          layout_width=-1,
          theme=MDC_R.style.Widget_MaterialComponents_TextInputLayout_OutlinedBox,
        },
      },
      {
        MaterialButton,
        id="searchButton",
        text="搜索",
        maxLines=1,
        layout_width="20%w",
        layout_gravity="center",
        layout_marginRight="10dp",
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      strokeWidth="0dp",
      layout_margin="6dp",
      layout_marginLeft="10dp",
      layout_marginRight="10dp",
      layout_marginBottom="6dp",
      cardBackgroundColor=Colors.colorSurfaceContainer,--colorSurfaceVariant
      --visibility=8,
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
          onClick=function()
            screening.visibility = screening.visibility == 0 and 8 or 0
          end,
          {
            AppCompatTextView,
            text="筛选",
            layout_weight=1,
            layout_gravity="center|left",
            layout_marginLeft="24dp",
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
            layout_margin="10dp",
            layout_marginRight="16dp",
          },
        },
        {
          LinearLayoutCompat,
          layout_width=-1,
          layout_height=-2,
          paddingLeft="16dp",
          paddingRight="16dp",
          orientation=1,
          id="screening",
          visibility=8,
          {
            ChipGroup,
            {
              Chip,
              text="WYY",
              id="wyyChip",
              checkable=true,
            },
            {
              Chip,
              text="BILI",
              id="biliChip",
              checkable=true,
            },
            {
              Chip,
              text="本地",
              id="localChip",
              checkable=true,
            },
            {
              Chip,
              text="收藏",
              id="loveChip",
              checkable=true,
            },
          },
          {
            ChipGroup,
            {
              Chip,
              text="歌名",
              id="songNameChip",
              checkable=true,
            },
            {
              Chip,
              text="歌手",
              id="singerNameChip",
              checkable=true,
            },
          },
        },
      },
    },
    {
      RecyclerView,
      layout_width=-1,
      layout_height=-1,
      layout_weight=1,
      id="totalMusicList",
    },
    {
      Space,
      layout_width=-1,
      layout_height="170dp",
    },
  },
  {
    ProgressBar,
    id="totalProgress",
    layout_centerInParent=true,
  },
}

