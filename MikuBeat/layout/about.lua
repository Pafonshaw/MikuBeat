

local NestedScrollView = luajava.bindClass "androidx.core.widget.NestedScrollView"
local MaterialCardView = luajava.bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = luajava.bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local FrameLayout = luajava.bindClass "android.widget.FrameLayout"
local AppCompatImageView = luajava.bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = luajava.bindClass "androidx.appcompat.widget.AppCompatTextView"
local Space = luajava.bindClass "android.widget.Space"


local function getCount(id)
  if id == 1
    local musicList = require "res.musicList"
    return tostring(#musicList)
   elseif id == 2
    local userAddManager = require "userAddManager"
    local userAdds = userAddManager.getUserAddMusic()
    return tostring(#userAdds)
   elseif id == 3
    local loveManager = require "loveManager"
    local loves = loveManager.getLoveMusic()
    return tostring(#loves)
   elseif id == 4
    local localMusicManager = require "localMusicManager"
    local locals = localMusicManager.getCacheMsgs()
    return tostring(#locals)
  end
end


return {
  NestedScrollView,
  layout_height=-1,
  layout_width=-1,
  fillViewport=true,
  {
    LinearLayoutCompat,
    layout_width=-1,
    layout_height=-1,
    orientation=1,
    layoutTransition=newLayoutTransition(400),
    {
      FrameLayout,
      layout_width=-1,
      {
        MaterialCardView,
        layout_height="110dp",
        layout_width=-1,
        layout_marginTop="48dp",
        layout_margin="16dp",
        cardBackgroundColor=Colors.colorSurfaceVariant,
        {
          AppCompatTextView,
          text="MikuBeat",
          layout_gravity="center|bottom",
          layout_marginBottom="10dp",
          textSize="24sp",
          textColor=Colors.colorOnBackground
        },
      },
      {
        MaterialCardView,
        radius="100dp",
        layout_gravity="center|top",
        strokeWidth=0,
        {
          AppCompatImageView,
          src="icon.png",
          layout_width="110dp",
          layout_height="110dp",
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      radius="15dp",
      layout_margin="16dp",
      strokeWidth=0,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        orientation=1,
        {
          LinearLayoutCompat,
          layout_width=-1,
          padding="10dp",
          backgroundColor=Colors.colorSurfaceContainer,
          {
            AppCompatTextView,
            text="曲库",
            textSize="15sp",
            textColor=Colors.colorOnBackground
          },
        },
        {
          LinearLayoutCompat,
          padding="10dp",
          layout_width=-1,
          backgroundColor=Colors.colorSurfaceVariant-0x88000000,
          {
            AppCompatTextView,
            text="内置列表:\t\t"..getCount(1).."\n添加曲目:\t\t"..getCount(2).."\n本地歌曲:\t\t"..getCount(4).."\n收藏:\t\t\t\t"..getCount(3),
            textSize="15sp",
            textColor=Colors.colorOnBackground
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      radius="15dp",
      layout_margin="16dp",
      strokeWidth=0,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        orientation=1,
        {
          LinearLayoutCompat,
          id="addDeveloper",
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          onClick=function()
            local Intent = luajava.bindClass "android.content.Intent"
            local Uri = luajava.bindClass "android.net.Uri"
            xpcall(function()
              activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("mqqapi://card/show_pslcard?src_type=internal&source=sharecard&version=1&uin=271607916")))
              end, function()
              copyText("271607916")
              local myToast = require "myToast"
              myToast.toast("跳转QQ异常，已复制QQ号")
            end)
          end,
          {
            LinearLayoutCompat,
            layout_width=-1,
            padding="10dp",
            backgroundColor=Colors.colorSurfaceContainer,
            {
              AppCompatTextView,
              text="开发者",
              textSize="18sp",
              textColor=Colors.colorOnBackground
            },
          },
          {
            LinearLayoutCompat,
            padding="10dp",
            layout_width=-1,
            backgroundColor=Colors.colorSurfaceVariant-0x88000000,
            {
              AppCompatTextView,
              text="Pafonshaw",
              textSize="15sp",
              textColor=Colors.colorOnBackground
            },
          },
        },
        {
          LinearLayoutCompat,
          id="thankDeveloper",
          layout_width=-1,
          layout_height=-1,
          orientation=1,
          onClick=function()
            local Intent = luajava.bindClass "android.content.Intent"
            local Uri = luajava.bindClass "android.net.Uri"
            xpcall(function()
              activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("mqqapi://card/show_pslcard?src_type=internal&source=sharecard&version=1&uin=271607916")))
              end, function()
              copyText("928182278")
              local myToast = require "myToast"
              myToast.toast("跳转QQ异常，已复制QQ号")
            end)
          end,
          {
            LinearLayoutCompat,
            layout_width=-1,
            padding="10dp",
            backgroundColor=Colors.colorSurfaceContainer,
            {
              AppCompatTextView,
              text="致谢",
              textSize="18sp",
              textColor=Colors.colorOnBackground
            },
          },
          {
            LinearLayoutCompat,
            padding="10dp",
            layout_width=-1,
            backgroundColor=Colors.colorSurfaceVariant-0x88000000,
            {
              AppCompatTextView,
              text="Xiayu\n\t--为开发工作提供大量指导性帮助",
              textSize="15sp",
              textColor=Colors.colorOnBackground
            },
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      radius="15dp",
      layout_margin="16dp",
      strokeWidth=0,
      {
        LinearLayoutCompat,
        id="joinUs",
        layout_width=-1,
        layout_height=-1,
        orientation=1,
        onClick=function()
          local Uri = luajava.bindClass "android.net.Uri"
          local Intent = luajava.bindClass "android.content.Intent"
          xpcall(function()
            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=912150197&card_type=group&source=qrcode")))
          end, function()
            copyText("912150197")
            local myToast = require "myToast"
            myToast.toast("跳转QQ异常，已复制群号")
          end)
        end,
        {
          LinearLayoutCompat,
          layout_width=-1,
          padding="10dp",
          backgroundColor=Colors.colorSurfaceContainer,
          {
            AppCompatTextView,
            text="交流群",
            textSize="15sp",
            textColor=Colors.colorOnBackground
          },
        },
        {
          LinearLayoutCompat,
          padding="10dp",
          layout_width=-1,
          backgroundColor=Colors.colorSurfaceVariant-0x88000000,
          {
            AppCompatTextView,
            text="点击添加交流群聊天&反馈BUG&建言献策&...",
            textSize="15sp",
            textColor=Colors.colorOnBackground
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      radius="15dp",
      layout_margin="16dp",
      strokeWidth=0,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        orientation=1,
        layoutTransition=newLayoutTransition(400),
        {
          LinearLayoutCompat,
          id="updateLogAbout",
          layout_width=-1,
          padding="10dp",
          backgroundColor=Colors.colorSurfaceContainer,
          onClick=function()
            updateLog.visibility = updateLog.visibility == 0 and 8 or 0
          end,
          {
            AppCompatTextView,
            text="更新日志",
            textSize="18sp",
            textColor=Colors.colorOnBackground
          },
        },
        {
          LinearLayoutCompat,
          padding="10dp",
          layout_width=-1,
          backgroundColor=Colors.colorSurfaceVariant-0x88000000,
          {
            NestedScrollView,
            layout_width=-1,
            layout_height="300dp",
            id="updateLog",
            visibility=8,
            fillViewport=true,
            {
              AppCompatTextView,
              text=[==[
0.3Release
  新增: 渐变色播放卡片
  新增: 音乐界面FAB按钮可拖动
  新增: 正式版可远程更新
  新增: 远程轮播图
  新增: 启动自动播放选项
  新增: 设置APP音量
  修复: 神奇的Miku掉线问题
  修复: 处理跳转QQ异常
  修复: 文件变故导致刷新本地列表报错
  修复: 爬取的html实体未转义
  修复: 哔站古老视频播放问题
  修复: 资源加载失败导致全局禁用
  优化: 提高了效率
  优化: 神奇的Miku接入deepseek_v3
  优化: 数据安全访问及存在判断
  优化: 公告与更新逻辑
  优化: WYY与B站添加曲目弹窗合并
0.2Release
  新增: 支持并融入解析B站
  新增: 支持并融入播放本地音频
  新增: 支持跳转MV
  修复: 轮播图失效
  修复: 若干小bug
  优化: 部分图标改用MDI
  优化: 暂停时可拖动进度条
  优化: 音乐界面FAB按钮逻辑优化
  优化: toast提示逻辑优化
0.1Release
  新增: 手动检测更新
  新增: 自动检测更新选项
  新增: Popup菜单删除单曲缓存
  修复: Popup菜单超出屏幕
  修复: 问问神奇的Miku失效
  优化: WY解析支持多种链接类型
  优化: 问问神奇的Miku优化
  优化: 设置页面音质选项适时显示与隐藏
 0.1Beta
  新增: 问问神奇的Miku
  新增: 轮播图*3
  新增: WY解析线路与解析音质选择
  修复: 点击回弹异常BUG
  修复: 播放卡片显示非当前播放歌曲BUG
  修复: 虚拟导航栏不适应BUG
  优化: 亖气文案优化
  优化: 缓存机制抗打断
  优化: 下载歌曲时禁止切歌以避免BUG
  - 删减: "启动自动播放"无效设置
 0.1Alpha
  新增: 开发了软件]==],
              textSize="15sp",
              textColor=Colors.colorOnBackground,
            },
          },
        },
      },
    },
    {
      MaterialCardView,
      layout_width=-1,
      layout_height=-2,
      radius="15dp",
      layout_margin="16dp",
      strokeWidth=0,
      {
        LinearLayoutCompat,
        layout_width=-1,
        layout_height=-1,
        orientation=1,
        layoutTransition=newLayoutTransition(400),
        {
          LinearLayoutCompat,
          id="permissionAndInformationAbout",
          layout_width=-1,
          padding="10dp",
          backgroundColor=Colors.colorSurfaceContainer,
          onClick=function()
            permissionAndInformation.visibility = permissionAndInformation.visibility == 0 and 8 or 0
          end,
          {
            AppCompatTextView,
            text="《MikuBeat 权限与信息说明》",
            textSize="18sp",
            textColor=Colors.colorOnBackground
          },
        },
        {
          LinearLayoutCompat,
          padding="10dp",
          layout_width=-1,
          backgroundColor=Colors.colorSurfaceVariant-0x88000000,
          {
            NestedScrollView,
            layout_width=-1,
            layout_height="300dp",
            id="permissionAndInformation",
            visibility=8,
            fillViewport=true,
            {
              AppCompatTextView,
              text=[==[
一、存储权限
    我们申请存储权限，旨在为您带来更便捷的使用体验。当您在 MikuBeat 中发现喜爱的歌曲想要保存音频文件或封面时，该权限将是必须的。
二、安装应用权限
    为了保证您能第一时间享受到 MikuBeat 正式版的最新功能与优化，我们需获取安装应用权限。每一次更新，都是我们对产品精益求精的追求，希望能为您带来更优质、更稳定的音乐播放环境。
三、启动次数统计
    我们设置了启动次数统计功能，但请您放心，这仅是在您每天首次打开应用时，对启动次数进行加一记录。这一操作不会涉及收集您的任何其他信息，我们仅希望通过这种方式，大致了解应用的日常使用频率，以便更好地优化产品服务。
四、远程代码
    MikuBeat 的远程代码功能，是我们精心为您准备的惊喜与保障。它主要用于适时添加彩蛋，让您在使用过程中收获意外的欢乐。同时，也会用于一些细微的功能微调，确保应用始终处于最佳状态。当然，这更是我们为您提供的 “备用支援”，以防万一出现突发状况，能迅速解决问题。我们承诺，所有远程代码在启用或关闭时，都会在官方群组内进行公示，详细告知代码内容及作用，让您对应用的运行情况了如指掌。

    我们始终将您的隐私与使用体验放在首位，感谢您对 MikuBeat 音乐播放器的信任与支持。]==],
              textSize="15sp",
              textColor=Colors.colorOnBackground,
            },
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
