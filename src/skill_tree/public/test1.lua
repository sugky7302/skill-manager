local require = require

local Test = require 'std.class'("TestNode", require 'skill_tree.node')
Test.register("test1", Test)  -- 註冊到node_list

function Test:_new()
    return self:super():new()
end

function Test:run()
    print("ha")
    self:success()
end
