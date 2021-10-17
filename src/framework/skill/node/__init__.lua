local class = require 'std.class'
local cls = class('Node')
local node_table = {}


function cls:_new(args)
    return {
        _args_ = args,
        parent_ = nil,
        tree_ = nil,
    }
end

function cls:__call(name, parent)
    if type(name) ~= 'string' then
        return false
    end

    if not node_table[name] then
        parent = parent or ''  -- 這樣容易處理，不需要考慮太多條件
        node_table[name] = class('ActionNode', node_table[parent] or pcall(require, parent) or self)
    end

    return node_table[name]
end

function cls:start()
end

function cls:run()
end

function cls:finish()
end

function cls:success()
    if self.parent_ then
        self.parent_:success()
    end
end

function cls:fail()
    if self.parent_ then
        self.parent_:fail()
    end
end

function cls:running()
    if self.parent_ then
        self.parent_:running()
    end
end

return cls
