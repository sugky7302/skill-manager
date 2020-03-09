local require = require
local Consumable = require 'std.class'("Consumable", require 'war3.item')

function Consumable:_new(item)
    return self:super():_new(item)
end

function Consumable:__call(item)
    return self:super().__call(self, item)
end

function Consumable:stack()
    if not self.owner_ then
        return false
    end

    -- BUG: unit:items迭代器還沒實現
    for _, item in self.owner_:items() do
        if item:getType() == self._type_ then
            item:addCharge(self:getCharge())
            self:remove()
            return
        end
    end
end

return Consumable
