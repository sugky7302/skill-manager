local A = require 'std.class'("A")

function A:_new()
    return {a=nil}
end

function A:a()
    print("a")
end

b = A:new()
b.a()
