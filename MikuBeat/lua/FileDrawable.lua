--取自梅花易排盘 By xiayu
local bindClass = luajava.bindClass
local activity = activity
local BitmapDrawable = bindClass "android.graphics.drawable.BitmapDrawable"
local BitmapFactory = bindClass "android.graphics.BitmapFactory"
local FileInputStream = bindClass "java.io.FileInputStream"

return function(file)
  local fis = FileInputStream(activity.getLuaDir().."/"..file)
  local bitmap = BitmapFactory.decodeStream(fis)
  return BitmapDrawable(activity.getResources(), bitmap)
end