local require = require
local ej, japi = require 'war3.enhanced_jass', require 'jass.japi'

return {
    file_key = '生命上限',
    set = function(self, value)
        japi.SetUnitState(self._object_, ej.UNIT_STATE_MAX_LIFE, value)
        self:set("生命", math.max(self:get("生命"), value))
    end,
    get = function(self)
        return ej.GetUnitState(self._object_, ej.UNIT_STATE_MAX_LIFE)
    end
}
