local require = require
local SkillTree = require 'lib.skill_tree.skill_tree'
local skill_decorator = require 'lib.skill_decorator':new()
local skill_manager = require 'lib.skill_manager':new()
local Hero = require 'std.class'("Hero", require 'war3.unit')

function Hero:_new(unit)
    return self:super():_new(unit)
end

function Hero:__call(unit)
    return self:super().__call(self, unit)
end

function Hero:decorateSkill(decorator_name)
    skill_decorator:append(self, decorator_name)
    return self
end

-- target必須是Unit或其子類別
function Hero:spell(skill_name, target, period)
    local skill = skill_manager:get(skill_name, self, target)
    return SkillTree:new(skill):append(skill.scripts):setPeriod(period):run()
end

return Hero
