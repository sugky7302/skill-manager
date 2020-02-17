local attr = require 'lib.attribute':new()

attr:set("物理攻擊力", 5)
attr:set("法術攻擊力", 10)

for name, value in attr:iterator() do
    print(name, value[1] * (1+value[2]/100))
end

attr:add("物理攻擊力%", 50)
attr:add("物理攻擊力", 100)
print(attr:get "物理攻擊力")
