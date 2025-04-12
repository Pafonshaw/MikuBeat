
local bindClass = luajava.bindClass
local require = require
local activity = activity
local Toast = bindClass "android.widget.Toast"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local Gravity = bindClass "android.view.Gravity"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local loadlayout = loadlayout
local Colors = Colors
local task = task

local _M = {}


local _toast
function _M.toast(text, time)
  if _toast _toast.cancel() end
  _toast = Toast.makeText(activity, text, time or Toast.LENGTH_SHORT).show()
  if time
    task(time, function() _toast.cancel() end)
  end
end

function _M.myToast(text, time)
  local layout = {
    LinearLayoutCompat;
    layout_width=-1;
    layout_height=-1;
    gravity="center",
    {
      MaterialCardView;
      layout_width=-2;
      layout_height=-2;
      CardBackgroundColor=Colors.colorSurfaceContainer;
      radius="24dp",
      {
        AppCompatTextView;
        layout_width="wrap";
        layout_height="wrap";
        layout_margin="16dp",
        textSize="16sp";
        TextColor="#ffeeeeee";
        gravity="center";
        text=text;
      };
    };
  };
  local toast = Toast.makeText(activity,"text",Toast.LENGTH_SHORT)
  .setView(loadlayout(layout))
  .setGravity(Gravity.BOTTOM,0,200)
  .show()
  if time
    task(time, function() toast.cancel() end)
  end
end


return _M

