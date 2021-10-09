local require, pcall, type = require, pcall, type
local cls = require 'std.class'("Equipment")
local RUNE, GEM = "符文", "珠寶"

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
        _rune_ = require 'war3.slot':new('data.test.rune'),
        _gem_ = require 'war3.slot':new(),
        _tick_ = require("data.item." .. type)  -- 自訂的obtain, drop, use
    }

    return Init(instance)
end

Init = function(self)
    local data = require('data.test.equipment'):read(self._type_)
    if not data then
        return self
    end

    for i, v in ipairs(data) do
        if type(v) == 'string' then
            self._attr_:set(v, data[i+1](self))
        end
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

function cls:mount(material, level)
    -- 利用Rune會自動搜尋資料庫，檢查它是不是符文
    local data = self._rune_:mount(material, level)

    -- 檢查是不是珠寶
    if not data then
        data = self._gem_:mount(material, level)
    end

    if not data then return self end

    self._attr_:add(data[2], data[3])

    return self
end

function cls:demount(type, index)
    local data
    if type == RUNE then
        data = self._rune_:demount(index)
    elseif type == GEM then
        data = self._gem_:demount(index)
    end

    if data then
        self._attr_:add(data[2], -data[3])
    end

    return nil
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
