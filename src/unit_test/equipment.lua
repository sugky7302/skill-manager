local Equipment = require 'war3.equipment'

local a = Equipment:new()

a:mount('crum', 3):mount('sde', 5)

print(a)

print("------")
a:demount("符文", 1)
print(a)