local require = require
local Hero = require 'std.class'("Hero", require 'war3.unit')

function Hero:_new(unit)
    return self:super():_new(unit)
end

function Hero:__call(unit)
    return self:super().__call(self, unit)
end

function Hero:decorateSkill(decorator_name)
    require 'lib.skill_decorator':append(self._object_, decorator_name)
    return self
end
