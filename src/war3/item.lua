local require = require
local ej = require 'war3.enhanced_jass'
local ascii = require 'std.ascii'
local Item = require 'std.class'("Item")

function Item:_new(item)
    local this = {
        _object_ = item,
        _id_ = ej.H2I(item),
        _type_ = ej.Item2S(item),
        owner_ = nil,
    }

    -- 將實例綁在類別上，方便呼叫
    self[item] = this
    return this
end

function Item:__call(item)
    return Item[item] or self:new(item)
end

function Item:getObject()
    return self._object_
end

function Item:getId()
    return self._id_
end

function Item:getType()
    return self._type_
end

return Item
