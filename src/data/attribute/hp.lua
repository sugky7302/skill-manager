local require = require
local ej = require 'war3.enhanced_jass'
local Math = require 'std.math'

return {
    file_key = '生命',
    set = function(self, value)
        if value > 0.3 then
            ej.SetWidgetLife(self._object_, value)
        else
            ej.removeUnit(self._object_)
        end
    end,
    get = function(self)
        return Math.bound(0, ej.GetWidgetLife(self._object_), self:get("生命上限"))
    end
}
