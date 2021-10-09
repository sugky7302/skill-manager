local Equipment = require 'war3.equipment'

local a = Equipment:new{id=123, type='sbch', name="test", level=5}

a:mount('crum', 3):mount('sde', 5)

print(a)

print("------")
a:demount("符文", 1)
print(a)

a:setOwner(1):equip():drop():use()

