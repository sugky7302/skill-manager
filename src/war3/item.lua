local require = require
local ej = require 'war3.enhanced_jass'
local Item = require 'std.class'("Item")

-- TODO: 預留讀取物品類型腳本的功能

function Item.create(item_type, loc)
    local item = ej.CreateItem(ej.decode(item_type), loc.x, loc.y)
    return item
end

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

function Item:_remove()
    ej.removeItem(self._object_)
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

function Item:addCharge(count)
    self:setCharge(self:getCharge() + count)
end

function Item:setCharge(count)
    count = math.max(count, 0)

    if count > 0 then
        ej.SetItemCharges(self._object_, count)
    else
        self:remove()
    end
end

function Item:getCharge()
    return ej.GetItemCharges(self._object_)
end


function Item:stack()
    return false
end

function Item:use()
end

function Item:obtain()
end

function Item:drop()
end

return Item
