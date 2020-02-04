local function Main()
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
end

Main()
