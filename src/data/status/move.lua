local ej = require 'war3.enhanced_jass'

return {
    name = '無法移動',
    set = function(self, status)
        if status then
            ej.SetUnitPropWindow(self.object_, 0)
        else
            ej.SetUnitPropWindow(self.object_, ej.GetUnitDefaultPropWindow(self.object_))
        end
    end,
}
