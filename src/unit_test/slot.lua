local Rune = require 'war3.slot'

local a = Rune:new('data.test.rune')

a:mount('crum', 3)
a:mount('sde', 10)
a:mount('crum', 8)
for i, node in a:iterator() do
    print(i, table.unpack(node:getData()))
end