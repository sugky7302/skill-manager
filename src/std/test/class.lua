local A = require 'std.class'("A")

function A:_new()
    return {
        _a = 1,
        _b = 2,
    }
end

A:getter("a", function(self)
    return self._a
end)

b = A:new()
print(b.a)
b.a = 3
print(b.a)

A:setter("b", function(self, v)
    self._a = v
end)

b.b = 3
print(b.a)

for k, v in pairs(b) do
    print(k, v)
end
