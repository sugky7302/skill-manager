local a = require 'std.array':new()
a:append(5)
a:append(4)
a:append(3)
a:append(2)
for i, v in a:reverseIterator() do
    print(i, v)
end
