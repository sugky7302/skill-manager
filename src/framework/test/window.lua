local require = require
local ej = require 'war3.enhanced_jass'
local Timer = require 'war3.timer'
local Window = require 'war3.window'
local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)

e:addEvent(
    "對話框-被點擊",
    "GetClickedDialog GetClickedButton",
    function(_, dialog, button)
        local window = Window(dialog)
        local text = window:findText(button)
        print("text", button, text)

        if text == "hihi" then
            window:add("del"):add("resize")
        elseif text == "del" then
            window:delete(button)
        elseif text == "resize" then
            window:setLength(10)
        end
    end
)

-- NOTE: 因為初始化時創建對話框會失敗，所以要用計時器延遲創建
Timer:new(0, 1, function()
    local d = Window:new(ej.Player(0))
    d:setTitle("測試"):add("hihi"):open()
end):start()



