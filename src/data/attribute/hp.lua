local require = require
local ej = require 'war3.enhanced_jass'
local Math = require 'std.math'

return {
    file_key = '生命',
    set = function(self, value)
        ej.SetWidgetLife(self._object_, Math.max(value, 1))
    end,
    get = function(self)
        return Math.bound(0, ej.GetWidgetLife(self._object_), self:get("生命上限"))
    end
}
