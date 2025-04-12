
local bindClass = luajava.bindClass
local activity = activity
local math = math
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local AlphaAnimation = bindClass "android.view.animation.AlphaAnimation"
--local MotionEvent = luajava.bindClass "android.view.MotionEvent"
local AnimatorSet = bindClass "android.animation.AnimatorSet"
--import "android.view.View"
local _M = {}

--水珠动画
function _M.waterAnim(v,t)
  ObjectAnimator().ofFloat(v,"scaleX",{1,.8,1.3,.9,1}).setDuration(t).start()
  ObjectAnimator().ofFloat(v,"scaleY",{1,.8,1.3,.9,1}).setDuration(t).start()
end

--[[单动画，大小单次变化
function _M.sizeAnim(view,xsize,size,time)
  ObjectAnimator().ofFloat(view,"scaleX",{xsize,size}).setDuration(time).start()
  ObjectAnimator().ofFloat(view,"scaleY",{xsize,size}).setDuration(time).start()
end
--]]

--[[设置点击回弹效果
function _M.onClickBounce(view,size,time, opposite)
  local size = size or 0.9
  local time = time or 100
  local beginSize = opposite and size or 1
  local endSize = opposite and 1 or size

  view.OnTouchListener=function(View,Event)
    if Event.getAction()==MotionEvent.ACTION_DOWN then
      _M.sizeAnim(view, beginSize, endSize, time)
     elseif Event.getAction()==MotionEvent.ACTION_UP then
      _M.sizeAnim(view, endSize, beginSize, time)
    end
  end
end
--]]

---[[
function _M.onClickBounce(view, size, duration)
  size = size or 0.85
  view.onTouch = function(v, event)
    local action = event.getAction()
    --print(action)
    if action == 0 then
      local down1 = ObjectAnimator.ofFloat(v, "scaleX", {v.getScaleX(), size})
      local down2 = ObjectAnimator.ofFloat(v, "scaleY", {v.getScaleY(), size})
      AnimatorSet().playTogether({down1, down2}).setDuration(duration or 120).start()
     elseif action == 1 or action == 3 then
      local up1 = ObjectAnimator.ofFloat(v, "scaleX", {v.getScaleX(), 1})
      local up2 = ObjectAnimator.ofFloat(v, "scaleY", {v.getScaleY(), 1})
      AnimatorSet().playTogether({up1, up2}).setDuration(duration or 120).start()
    end
    --return false
  end
end
--]]

local function dp2px(dpValue)
  local scale = activity.getResources().getDisplayMetrics().density;
  return dpValue * scale + 0.5
end

function _M.addFunc(view)
  local size = 0.96
  local touchX, touchY --初始触摸点相对于屏幕左上角的坐标
  local firstX, firstY --初始控件左上角相对于父控件左上角的坐标
  local h = activity.getHeight()
  local w = activity.getWidth()
  local function checkx(x)
    if x > dp2px(40) and x + dp2px(40) < w
      return true
    end
    return false
  end
  local function checky(y)
    if y > dp2px(150) and y + dp2px(170) < h
      return true
    end
    return false
  end
  view.onTouch = function(v, event)
    local action = event.getAction()
    if action==0 then
      local down1 = ObjectAnimator.ofFloat(v, "scaleX", {v.getScaleX(), size})
      local down2 = ObjectAnimator.ofFloat(v, "scaleY", {v.getScaleY(), size})
      AnimatorSet().playTogether({down1, down2}).setDuration(200).start()
      touchX = event.getRawX()
      touchY = event.getRawY()
      firstX = v.getX()
      firstY = v.getY()
      flag=false
     elseif action==2 then
      if checkx(event.getRawX())
        v.x = firstX + (event.getRawX() - touchX)
      end
      if checky(event.getRawY())
        v.y = firstY + (event.getRawY() - touchY)
      end
     elseif action == 1 or action == 3 then
      local up1 = ObjectAnimator.ofFloat(v, "scaleX", {v.getScaleX(), 1})
      local up2 = ObjectAnimator.ofFloat(v, "scaleY", {v.getScaleY(), 1})
      AnimatorSet().playTogether({up1, up2}).setDuration(200).start()
    end
    if math.abs(event.getRawX() - touchX) > dp2px(1) and math.abs(event.getRawY() - touchY) > dp2px(1)
      addLongClickFlag = false
      return true
     else
      addLongClickFlag = true
      return false
    end
    --return true
  end
end

--TP transparency 透明
function _M.TPAnim(id, time, beginTP, endTP)
  if beginTP==1 then
    id.setVisibility(0)
  end
  id.startAnimation(AlphaAnimation(beginTP, endTP).setDuration(time))
  if endTP==0 then
    id.setVisibility(8)
  end
  if endTP==1 then
    id.setVisibility(0)
  end
end


return _M
