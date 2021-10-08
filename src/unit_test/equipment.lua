local Equipment = require 'war3.equipment'

local a = Equipment:new(123, 'data.item.sbch')

a:mount('crum', 3):mount('sde', 5)

print(a)

print("------")
a:demount("符文", 1)
print(a)

a:setOwner(1):equip():drop():use()

