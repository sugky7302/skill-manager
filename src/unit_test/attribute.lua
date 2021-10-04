local attr = require 'lib.attribute':new():setPackage('data.test.attribute')

local function loop()
    for priority, name in attr:iterator() do
        print(priority, name, attr:sum(name), attr:get(name), attr:getDescription(name))
    end
end

attr:set("a", 5):set("b", 10)
loop()


attr:add("a%", 50):add("a", 100):add("a*", 10):add("a@", 20)
print(attr:get "a", attr:get "a*", attr:get "a@")

attr:delete("a")

loop()

print(attr:getProperty("c", "res"))  -- nil(no this attribute)
print(attr:getProperty("b", "res"))  -- nil(no this property)
print(attr:getProperty("a", "res"))  -- hello world
