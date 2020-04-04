local require = require
local ej = require 'war3.enhanced_jass'
local Timer = require 'war3.timer'
local Window = require 'war3.window'
local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)

e:addEvent(
    "對話框-被點擊",
    "GetTriggerPlayer GetClickedButton",
    function(_, player, button)
        local window = Window(player)
        local text = window:findText(button)
        print("text", button, text)
        if text == "hihi" then
            window:add("delete"):add("change length")
        elseif text == "delete" then
            window:delete(button)
        elseif text == "change length" then
            window:setLength(10)
        elseif window:isPrev(button) then
            window:prev()
        elseif window:isNext(button) then
            window:next()
        end
    end
)

-- NOTE: 因為初始化時創建對話框會失敗，所以要用計時器延遲創建
Timer:new(0, 1, function()
    local d = Window:new(ej.Player(0))

    l("對話框-被點擊")(d:getObject())
    d:setTitle("測試"):add("hihi"):open()
end):start()



