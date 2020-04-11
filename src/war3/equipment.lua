local require = require
local Attribute = require 'lib.attribute'
local Equipment = require 'std.class'("Equipment", require 'war3.item')


function Equipment:_new(item)
    local instance = self:super():_new(item)
    instance._attribute_ = Attribute:new(item)
    return instance
end

function Equipment:__call(item)
    return self:super().__call(self, item)
end

function Equipment:attributes()
    return self._attribute_:iterator()
end

function Equipment:addAttribute(name, value)
    self._attribute_:add(name, value)
    return self
end

function Equipment:deleteAttribute(name)
    self._attribute_:delete(name)
    return self
end

function Equipment:obtain()
    if not self.owner_ then
        return
    end

    for name, _ in self._attribute_:iterator() do
        self.owner_:addAttribute(name, self._attribute_:get(name))
    end
end

function Equipment:drop()
    if not self.owner_ then
        return
    end

    for name, _ in self._attribute_:iterator() do
        self.owner_:addAttribute(name, -self._attribute_:get(name))
    end
end

return Equipment
