local ej = require 'war3.enhanced_jass'

return {
    file_key = "生命",
    set = function(self, life)
        ej.SetWidgetLife(self._object_, math.max(life, 1))
    end,
    get = function(self)
        return ej.GetWidgetLife(self._object_)
    end
}
