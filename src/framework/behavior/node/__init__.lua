local class = require 'std.class'
local cls = class('Node')
local node_table = {}

function cls.exist(name)
    return name and node_table[name]
end

function cls:_new(args)
    return {
        _args_ = args,
        _name_ = nil,
        parent_ = nil,
        tree_ = nil,
    }
end

function cls:__call(name, parent, type_name)
    local type = type
    if type(name) ~= 'string' then
        return false
    end

    if not node_table[name] then
        if type(parent) == 'table' then
            node_table[name] = class(type_name or 'ActionNode', parent)
        elseif type(parent) == "string" then
            node_table[name] = class(type_name or 'ActionNode', node_table[parent] or pcall(require, parent) or self)
        else
            node_table[name] = class(type_name or 'ActionNode', self)
        end

        node_table[name]._name_ = name
    end

    return node_table[name]
end

function cls:getName()
    return self._name_
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

function cls:Break()
    if self.parent_ then
        self.parent_:Break()
    end
end

function cls:continue()
    if self.parent_ then
        self.parent_:continue()
    end
end

return cls
