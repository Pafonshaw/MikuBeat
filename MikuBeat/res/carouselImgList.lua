
local backUrls = {
  "https://s21.ax1x.com/2025/01/13/pEPonN8.jpg",
  "https://s21.ax1x.com/2025/01/13/pEPoZHP.jpg",
  "https://s21.ax1x.com/2025/01/13/pEPIOXR.jpg",
}

--[[local types = {
  "booru-lewd",
  "booru-lisu",
  "booru-qualityhentais",
  "capoo-2",
  "gelbooru",
  "green",
  "moebooru",
  "original-new",
  "original-old",
  "rule34",
}


local timeUrl = (function()
  math.randomseed(tointeger(os.clock()*10000+os.time())) --设置一个高随机性种子
  return "https://count.littlebell.top/@mikubeattest?name=mikubeattest&theme="..types[math.random(1, 10)].."&padding=7&offset=0&scale=1&pixelated=1&darkmode=auto&prefix=39"
end)()

table.insert(backUrls, timeUrl)]]

return function(callback)
  Http.get("http://8.218.86.120/main/photo/list.php?admin=271607916&dir_name=MikuBeat", function(code, content)
    if code == 200
      local cjson = require "cjson"
      local ok, urls = pcall(cjson.decode, content)
      if ok and urls.code == 1
        local imgs = {}
        for i = 1, #urls.data
          table.insert(imgs, urls.data[i].link)
        end
        --table.insert(imgs, timeUrl)
        callback(imgs)
       else
        callback(backUrls)
        local myToast = require "myToast"
        myToast.toast("轮播图文档异常\n(当前尝试使用备用轮播图)")
      end
     else
      callback(backUrls)
      local myToast = require "myToast"
      myToast.toast("轮播图信息获取异常\n(当前尝试使用备用轮播图)")
    end
  end)
end

