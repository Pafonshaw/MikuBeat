local activity = activity
local packageManager = activity.getPackageManager()
local packageName = activity.getPackageName()

return {
  ["icon"] = packageManager.getApplicationIcon(packageName),
  ["name"] = packageManager.getApplicationLabel(packageManager.getApplicationInfo(packageName, 0)),
  ["versionName"] = packageManager.getPackageInfo(packageName, 0).versionName,
  --["app_user"] = activity.getDataDir(),
  ["developer"] = "Pafonshaw",
  --["path"] = "/storage/emulated/0/Android/data/" .. packageName,
}