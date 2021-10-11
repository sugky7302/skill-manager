local require, pcall, type = require, pcall, type
local cls = require 'std.class'("Equipment")

function cls:_new(t)
    local instance = {
        _id_ = t.id,  -- item在遊戲裡的id
        _type_ = t.type, -- item在遊戲裡的type
        _owner_ = nil,
        _name_ = t.name,
        _level_ = t.level,
        _prefix_ = nil,
        _enhanced_times_ = 0,
        _vitality_ = 0,
        _attr_ = require 'lib.attribute':new():setPackage('data.test.attribute'),
        _stargraph_ = require 'war3.stargraph':new(),
        _tick_ = require("data.item." .. type)  -- 自訂的obtain, drop, use
    }

    return Init(instance)
end

Init = function(self)
    local data = require('data.test.equipment'):read(self._type_)
    if not data then
        return self
    end

    for _, attr in ipairs(data) do
        self._attr_:set(attr, require '':read(attr)[2](self.level))
        self._stargraph_:addPlanet(attr)
    end

    return self
end

function cls:setOwner(owner)
    self._owner_ = owner
    return self
end

function cls:getName()
    return (self._prefix_ or "") .. (self._name_ or "")
end

function cls:__tostring()
    return self:show()
end

function cls:show()
    local str = {}
    for _, name in self._attr_:iterator() do
        if self._attr_:get(name) > 0 then
            str[#str+1] = "◆" .. self._attr_:getDescription(name)
        end
    end

    return table.concat(str, "\n")
end

-- rune = item type
function cls:mount(rune, level)
    local data = require '':read(rune)

    if not data then
        return false
    elseif data[1] == "符文" and not self._stargraph_:addPlanet(rune) then
        return false
    elseif data[1] == "次級符文" and self._stargraph_:addSatellite(rune) then
        return false
    end
    
    for i, v in ipairs(data) do
        if type(v) == 'string' then
            self._attr_:add(v, data[i+1](level))
        end
    end

    return true
end

function cls:equip()
    if not self._owner_ then
        return self
    end

    if type(self._owner_) == "table" and self._owner_:isType("Unit") then
        self._owner_._attr_ = self._owner_._attr_ + self._attr_
    end

    pcall(self._tick_.equip, self)

    return self
end

function cls:drop()
    if not self._owner_ then
        return self
    end

    if type(self._owner_) == "table" and self._owner_:isType("Unit") then
        self._owner_._attr_ = self._owner_._attr_ - self._attr_
    end

    pcall(self._tick_.drop, self)

    return self
end

function cls:use(target)
    if self._owner_ then
        pcall(self._tick_.use, self, target)
    end
    return self
end

return cls
