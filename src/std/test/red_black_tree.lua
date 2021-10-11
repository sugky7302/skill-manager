local RBT = require 'std.red_black_tree':new()
RBT:insert(1, "a")
RBT:insert(5, "b")
RBT:insert(3, "c")
RBT:insert(0, "d")

for i, v in RBT:iterator() do
    print(i, v)
end

RBT:delete(3)

for i, v in RBT:iterator() do
    print(i, v)
end
