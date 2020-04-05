local attr = require 'lib.attribute':new():setPackage('data.test.attribute')

local function loop()
    for name, value in attr:iterator() do
        print(name, value[1] * (1+value[2]/100))
    end
end

attr:set("a", 5):set("b", 10)
loop()


attr:add("a%", 50):add("a", 100)
print(attr:get "a")

attr:delete("a")

loop()
