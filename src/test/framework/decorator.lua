local function test1(node)
    local fn = node.run
    node.run = function(self)
        print(2)
        fn()
    end
end

local a = require 'framework.behavior.tree.decorator':new(
    {"測試1-a", "測試2-a", "測試1-b", "測試1-c", "測試3-a", "測試4-a", "測試2-c"},
    {test1, function() print(1) end, function() print(1) end, function() print(1) end,
    function() print(1) end, function() print(1) end, function() print(1) end})

a:add("測試4-b", function() print(1) end)
print(a)

local b = require 'framework.behavior.node'("測試1")

function b:run()
    print(1)
end

b = b:new()
a:wrap(b, {"測試1-a"})
b:run()
print("****")
a:wrap(b)
b:run()