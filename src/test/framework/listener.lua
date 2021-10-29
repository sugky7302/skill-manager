local a = require 'framework.listener':new(1048591)  -- 遊戲裡的血法師的id
print(a:object())
a:add("測試", nil, function() print('ASD') end):add("測試", nil, function(i) print("testing", i) end):add("測試", nil, function(i) print(i, "1896") end):add("測試")
a:onTick("測試", 10)

for arg, callback in a:iterator("測試") do
    print(arg, callback)
end

-- war3 測試
a:add(
    "單位-受到傷害",
    "GetTriggerUnit",
    function(u)
        print(u .. " is damaged. Please help him.")
    end
):add("單位-受到傷害", nil, function(u) print("I'm good") end)

for arg, callback in a:iterator("單位-受到傷害") do
    print("check")
end

local b = require 'framework.listener':new(1048590) -- 遊戲裡的強盜的id
b:add(
    "單位-受到傷害",
    "GetEventDamageSource",
    function(u)
        print(u .. " hurt someone.")
    end
):add("單位-受到傷害", nil, function(u) print("I'm bad") end)
