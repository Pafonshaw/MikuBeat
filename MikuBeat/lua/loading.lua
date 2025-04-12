local bindClsss = luajava.bindClass
local MaterialAlertDialogBuilder = bindClsss("com.google.android.material.dialog.MaterialAlertDialogBuilder")
local ProgressBar = bindClsss("android.widget.ProgressBar")
local AppCompatTextView = bindClsss("androidx.appcompat.widget.AppCompatTextView")
local LinearLayoutCompat = bindClsss("androidx.appcompat.widget.LinearLayoutCompat")

local LoadingDialog = {}
local isInit = false
local dialog = MaterialAlertDialogBuilder(activity)
local views = {}
local layout = {}
local defaultText = "加载中..."

local function init()
  layout = {
    LinearLayoutCompat,
    layout_width=-1,
    padding="16dp",
    paddingStart="20dp",
    paddingEnd="20dp",
    gravity="center|start",
    {
      ProgressBar,
    },
    {
      AppCompatTextView,
      id="text",
      text=defaultText,
      layout_marginStart="20dp",
      --textColor=Colors.colorOnSurface,
      textSize="16sp",
    },
  }
  dialog.setTitle("请稍等")
  dialog.setView(loadlayout(layout, views))
  dialog.setCancelable(false)
  dialog = dialog.create()
  isInit = true
end

function LoadingDialog.show(text)
  if not isInit then
    init()
  end
  views.text.setText(text or defaultText)
  dialog.show()
end

function LoadingDialog.dismiss()
  dialog.dismiss()
end

return LoadingDialog