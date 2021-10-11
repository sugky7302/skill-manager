local japi = require 'jass.japi'

return {
    name = '最大攻擊力',
    set = function(self, value)
        -- 設定骰子數量、骰子面數
        japi.SetUnitState(self.object_, 0x10, 1)
        japi.SetUnitState(self._object_, 0x11, math.max(1, value - self:get("最小攻擊力")))
    end,
    get = function(self)
        return japi.GetUnitState(self._object_, 0x12) +
            japi.GetUnitState(self._object_, 0x10) * japi.GetUnitState(self._object_, 0x11)
    end
}
