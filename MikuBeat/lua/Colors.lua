local bindClass = luajava.bindClass
--local MDC_R = bindClass "com.google.android.material.R"
local MaterialColors = bindClass "com.google.android.material.color.MaterialColors"

local DEFAULT_STATE = android.R.attr.state_enabled

local get = function(table, key)
  local val
  pcall(function()
    val = table[key]
  end)
  return val
end

local getAttr = function(name)
  return get(MDC_R.attr, name) or get(android.R.attr, name)
end

return setmetatable({}, {
  __index = function(self, key)
    return get(MaterialColors, key) or MaterialColors.getColor(activity, getAttr(key), DEFAULT_STATE)
  end
})