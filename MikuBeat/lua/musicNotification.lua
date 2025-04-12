

local MediaSession = luajava.bindClass "android.media.session.MediaSession"
local PendingIntent = luajava.bindClass "android.app.PendingIntent"
local Intent = luajava.bindClass "android.content.Intent"
local Notification = luajava.bindClass "android.app.Notification"
local Build = luajava.bindClass "android.os.Build"
local Context = luajava.bindClass "android.content.Context"
local NotificationManager = luajava.bindClass "android.app.NotificationManager"
local NotificationChannel = luajava.bindClass "android.app.NotificationChannel"
local BroadcastReceiver = luajava.bindClass "android.content.BroadcastReceiver"
local IntentFilter = luajava.bindClass "android.content.IntentFilter"

local AR = luajava.bindClass "android.R$drawable"


local _M = {}



-- 创建通知渠道（适用于 Android 8.0 及以上）
if (Build.VERSION.SDK_INT >= 26) then
  local channel = NotificationChannel("MikuBeat39", "Music Player", NotificationManager.IMPORTANCE_HIGH)
  notificationManager = this.getSystemService(Context.NOTIFICATION_SERVICE)
  notificationManager.createNotificationChannel(channel)
end


-- 创建媒体会话
local mediaSession = MediaSession(this, "MusicService")

-- 创建PendingIntent
--local loveIntent = Intent()
--loveIntent.setAction("android.intent.action.LOVE")
--local lovePendingIntent = PendingIntent.getBroadcast(this, 0, loveIntent, PendingIntent.FLAG_UPDATE_CURRENT)

local playIntent = Intent()
playIntent.setAction("MikuBeat.39.PLAY")
local playPendingIntent = PendingIntent.getBroadcast(this, 0, playIntent, PendingIntent.FLAG_UPDATE_CURRENT)

local nextIntent = Intent()
nextIntent.setAction("MikuBeat.39.NEXT")
local nextPendingIntent = PendingIntent.getBroadcast(this, 1, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT)


local prevIntent = Intent()
prevIntent.setAction("MikuBeat.39.PREV")
local prevPendingIntent = PendingIntent.getBroadcast(this, 2, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT)

--local orderIntent = Intent()
--orderIntent.setAction("android.intent.action.ORDER")
--local orderPendingIntent = PendingIntent.getBroadcast(this, 0, orderIntent, PendingIntent.FLAG_UPDATE_CURRENT)

local notificationBuilder = Notification.Builder(this, "MikuBeat39")
.setSmallIcon(R.drawable.icon)
.setPriority(Notification.PRIORITY_MAX)
.setStyle(Notification.MediaStyle()
.setMediaSession(mediaSession.getSessionToken())
.setShowActionsInCompactView({0, 1, 2}))
.setProgress(0, 0, false)
.setOngoing(true)
.addAction(AR.ic_media_previous, "上一首", prevPendingIntent)

local callback = {
  mPlay = function() end,
  mNext = function() end,
  mPrev = function() end,
}


local receiver
function _M.create()
  receiver = BroadcastReceiver{
    onReceive = function(context, intent)
      local action = intent.getAction()
      if action == "MikuBeat.39.PLAY" then
        callback.mPlay()
       elseif action == "MikuBeat.39.NEXT" then
        callback.mNext()
       elseif action == "MikuBeat.39.PREV" then
        callback.mPrev()
      end
    end
  }
  local filter = IntentFilter()
  filter.addAction("MikuBeat.39.PLAY")
  filter.addAction("MikuBeat.39.NEXT")
  filter.addAction("MikuBeat.39.PREV")
  activity.registerReceiver(receiver, filter)
end



function _M.setBroadcastReceiver(func1, func2, func3)
  callback.mPlay = func1
  callback.mNext = func2
  callback.mPrev = func3
end


local lastTitle
local lastArtist
local lastCover

function _M.updateNotification(isPlaying, title, artist, cover) --cover-bitmap
  
  if title lastTitle = title else title = lastTitle end
  if artist lastArtist = artist else artist = lastArtist end
  if cover lastCover = cover else cover = lastCover end

  --创建通知
  notificationBuilder
  .setContentTitle(title)
  .setContentText(artist)
  .setLargeIcon(cover)
  .addAction((isPlaying and AR.ic_media_pause or AR.ic_media_play), isPlaying and "暂停" or "播放", playPendingIntent)
  .addAction(AR.ic_media_next, "下一首", nextPendingIntent)

  notificationManager.notify(39, notificationBuilder.build())
end

--_M.setBroadcastReceiver(function() print(1) end, function() print(2) end, function() print(3) end)
--_M.updateNotification(true, "t", "t")


function _M.destroyNotification()
  local manager = this.getSystemService(Context.NOTIFICATION_SERVICE)
  manager.cancel(39)
  activity.unregisterReceiver(receiver)
end



return _M

