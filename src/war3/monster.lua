local require = require
local ej = require 'war3.enhanced_jass'

local Monster = require 'std.class'('Monster', require 'war3.unit')
local InitAttribute, SetRevivePoint

function Monster:_new(unit)
    local monster = self:super():_new(unit)
    SetRevivePoint(monster)
    return InitAttribute(monster)
end

SetRevivePoint = function(self)
    self._revive_point_ = require 'std.point':new(ej.GetUnitX(self._object_), ej.GetUnitY(self._object_))
end

InitAttribute = function(self)
    local unit_data = require 'jass.slk'.unit[require 'std.ascii'.encode(ej.U2Id(self._object_))]

    if not unit_data then
        return self
    end

    self._attribute_:set('刷新時間', unit_data.stockRegen)
    return self
end

-- NOTE: 還是要寫一個__call調用Unit:__call，無法直接調用。
function Monster:__call(unit)
    return self:super().__call(self, unit)
end

return Monster
