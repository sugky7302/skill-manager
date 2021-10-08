local vector = require 'std.vector'

local a, b = vector(1, 2, 3), vector{3, 4, 5}
print(a, b)
print(a+b, a-b, a*b, a*3, b/5)
print(a:norm(), b:unit())
print(a == b, a < b, a > b)