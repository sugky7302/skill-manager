local Equipment = require 'framework.equipment'
Equipment.setPackage('framework.test.db.attribute',
                     'framework.test.db.item',
                     'framework.test.db.attribute_value')
local a = Equipment:new{id=123, type='def', name="test", level=25}

print(a)

a:mount('crum', 3)
a:mount('sde', 5, 4)
a:mount('s', 3, 1)
a:mount('d', 5, 3)
a:mount('e', 7, 5)
a:mount('ae', 10, 6)
print(a:mount('aq', 8, 2))
print(a:mount('e', 8, 4))

print(a)

a:setOwner(1):equip():drop():use()

