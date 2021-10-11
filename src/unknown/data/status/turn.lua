local ej = require 'war3.enhanced_jass'

return {
    name = '無法轉身',
    set = function(self, status)
        ej.SetUnitTurnSpeed(self.object_, status and 0 or 0.5)
    end,
}
