local require = require
local ej = require 'war3.enhanced_jass'

local SpellStart = require 'std.class'("ActionNode", require 'lib.skill_tree.node')
SpellStart:register("詠唱")  -- 註冊到node_list

function SpellStart:_new(args)
    local instance = self:super():new()
    instance.time_ = args[1]
    return instance
end

function SpellStart:start()
    self.remaining_ = self.time_
end

function SpellStart:run()
    print("remain: " .. self.remaining_)

    if self.remaining_ <= 0 then
        self:success()
        return
    end

    self.remaining_ = self.remaining_ - self.tree_.period_
    self:running()
end

local FlameStrike = require 'std.class'("ActionNode", require 'lib.skill_tree.node')
FlameStrike:register("烈焰風暴")  -- 註冊到node_list

function FlameStrike:_new()
    return self:super():new()
end

function FlameStrike:run()
    ej.DestroyEffect(ej.AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl", 0., 0.))
    ej.AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl", 0., 0.)
    ej.AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl", 0., 0.)
    self.tree_.is_finished_=  true
    self:success()
end

return {
    name = "烈焰風暴",
    scripts = {
        {id = "詠唱", args = {2}},
        {id = "烈焰風暴"},
    },
}
