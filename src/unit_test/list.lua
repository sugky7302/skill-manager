local a = require 'std.list':new()
a:push_back(1)
a:push_back(2)
a:push_back(3)
a:push_back(4)

for i, node in a:iterator() do
    print(i, node:getData())
    if node:getData() == 2 then
        a:insert(node, 5)
        break
    end
end

print(a)

-- 單獨調用迭代器
-- a:iterator()只是一個函數，必須要再加()才會調用
print(a:iterator()())


-- 多層迭代器參考寫法，主要是別的類別的迭代器要調用本迭代器進行處理，需要額外做一些工作
local function test()
    local list = require 'std.list':new()
    list:push_back(1)
    list:push_back(2)
    list:push_back(3)
    list:push_back(4)
    list:push_back(5)
    local f = list:iterator()  -- 
    return function()
        local i, node = f()
        if not i then
            return nil
        end
        return i, node:getData()
    end
end

for i, v in test() do
    print(i, v)
end
