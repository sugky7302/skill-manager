local require = require

local Test = require 'std.class'("TestNode", require 'lib.skill_tree.node')
Test:register("test")  -- 註冊到node_list

function Test:_new()
    return self:super():new()
end

function Test:run()
    print("hello world")
    self:running()
end

return {
    text = "測試",
    name = "a",
}
