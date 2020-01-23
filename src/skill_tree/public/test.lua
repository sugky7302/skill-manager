local require = require

local Test = require 'std.class'("TestNode", require 'skill_tree.node')
Test.register("test", Test)  -- 註冊到node_list

function Test:_new()
    return self:super():new()
end

function Test:run()
    print("hello world")
    self:success()
end
