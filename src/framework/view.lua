local require = require
local Timer = require 'war3.timer'
local ej = require 'war3.enhanced_jass'
return {
    new = function(self, path, x, y, time)
        local view = {
            __index = self,
            _path_ = path,
            _x_ = x,
            _y_ = y,
            _time_ = time < 0 and 0 or time,
        }

        return setmetatable(view, view)
    end,
    start = function(self)
        if self._time_ == 0 then
            ej.DestroyEffect(ej.AddSpecialEffect(self._path_, self._x_, self._y_))
        else
            local effect = ej.AddSpecialEffect(self._path_, self._x_, self._y_)
            Timer:new(
                self._time_,
                1,
                function()
                    ej.DestroyEffect(effect)
                end
            ):start()
        end
    end
}
