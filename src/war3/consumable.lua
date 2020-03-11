local require = require
local Consumable = require 'std.class'("Consumable", require 'war3.item')

function Consumable:_new(item)
    return self:super():_new(item)
end

function Consumable:__call(item)
    return self:super().__call(self, item)
end

function Consumable:stack(user)
    if not user or user.type ~= "Hero" then
        return false
    end

    for _, item in user:items() do
        if item:getType() == self._type_ then
            item:addCharge(self:getCharge())
            self:remove()
            return true
        end
    end

    return false
end

return Consumable
