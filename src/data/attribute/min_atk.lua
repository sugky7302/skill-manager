local japi = require 'jass.japi'

return {
    name = '最小攻擊力',
    set = function(self, value)
        -- -1是讓面板顯示正常
        japi.SetUnitState(self._object_, 0x12, value - 1)

        self:set('最大攻擊力', math.max(self:get('最大攻擊力!'), value))
    end,
    get = function(self)
        return japi.GetUnitState(self._object_, 0x12) + 1
    end
}
