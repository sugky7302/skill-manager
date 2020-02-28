local ej = require 'war3.enhanced_jass'

return {
    file_key = '轉身速度',
    set = function(self, value)
        ej.SetUnitTurnSpeed(self.object_, value)
    end,
    get = function(self)
        return ej.GetUnitTurnSpeed(self._object_)
    end
}
