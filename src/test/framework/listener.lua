local a = require 'framework.listener':new(1048591)  -- 遊戲裡的血法師的id
print(a:object())
a:addEvent("測試", function() print(2) end):addEvent("測試", function(i) print(i) end):addEvent("測試", function(i, this) print(i + this:object() * 2) end)
a:onTick("測試", 10)
a:addBroadcast(
    "單位-受到傷害",
    "GetTriggerUnit",
    function(u)
        print(u .. " is damaged. Please help him.")
    end
):addEvent("單位-受到傷害", function(u) print("I'm good") end)

local b = require 'framework.listener':new(1048590) -- 遊戲裡的強盜的id
b:addBroadcast(
    "單位-受到傷害",
    "GetEventDamageSource",
    function(u)
        print(u .. " hurt someone.")
    end
):addEvent("單位-受到傷害", function(u) print("I'm bad") end)
