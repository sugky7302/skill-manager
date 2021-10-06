local require = require
local cls = require 'std.class'("Equipment")
local RUNE, GEM = "符文", "珠寶"

function cls:_new()
    return {
        _owner_ = nil,
        _name_ = nil,
        _level_ = 0,
        _prefix_ = nil,
        _enhanced_times_ = 0,
        _vitality_ = 0,
        _attr_ = require 'lib.attribute':new(),
        _rune_ = require 'war3.rune':new('data.test.rune'),
        _gem_ = require 'war3.rune':new(),
    }
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
    -- 利用Rune會自動搜尋資料庫的功能，先檢查它是不是符文
    local data = self._rune_:mount(material, level)

    -- 再撿查是不是珠寶
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
end

function cls:drop()
end

function cls:use()
end

return cls
