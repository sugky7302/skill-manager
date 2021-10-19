local attr = require 'frame.attribute':new():setPackage('data.test.attribute')

local function loop(a)
    for priority, name in a:iterator() do
        print(priority, name, a:sum(name), a:get(name), a:getDescription(name))
    end
end

attr:set("a", 5):set("b", 10)
loop(attr)


attr:add("a%", 50):add("a", 100):add("a*", 10):add("a@", 20)
print(attr:get "a", attr:get "a*", attr:get "a@")

attr:delete("a")

loop(attr)

print(attr:getProperty("c", "res"))  -- nil(no this attribute)
print(attr:getProperty("b", "res"))  -- nil(no this property)
print(attr:getProperty("a", "res"))  -- hello world

local b = require 'lib.attribute':new()
print(b:get('a'))
b:set('c', 15):add('c%', 7):set('b*', 100):add('a', 12)

loop(b)

local c = require 'lib.attribute':new():setPackage('data.test.rune')
c:set('cruw', 3)
