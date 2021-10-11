local Matrix = require 'std.matrix'

local a,b = Matrix{{1, 2}, {3, 4}, {5, 6}}, Matrix{{5,4}, {6,1}, {2,3}}

for i, j, v in a:iterator() do
    print(table.concat{"M(", i, ",", j, ") = ", v})
end

print(a == b, a + b, a * b:transpose(), a*2, b/ 3)

local c = require 'std.vector'(7, 8, 9)
print(c*a)

print(a:transpose() * c)