local PQ = require 'std.priority_queue'

a = PQ:new()
a:push(1, 'a'):push(3, 'b'):push(4, 'c')

for _, v in a:iterator() do
    print(v[1], v[2])
end