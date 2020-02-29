local require = require
local View = require 'war3.view'
local Unit = require 'war3.unit'
local ej = require 'war3.enhanced_jass'
local Group = require 'war3.group'
local EffectManager = require 'lib.effect_manager'
local Class = require 'std.class'

local FlameStrike = Class('ActionNode', require 'lib.skill_tree.node')
FlameStrike:register('烈焰風暴') -- 註冊到node_list

function FlameStrike:_new()
    return self:super():_new()
end

function FlameStrike:run()
    local x, y = ej.GetLocationX(self.tree_.skill_.target), ej.GetLocationY(self.tree_.skill_.target)
    self.tree_:setParam('x', x)
    self.tree_:setParam('y', y)

    View:new('Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl', x, y, 0):start()
    View:new('Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl', x, y, 2):start()

    self:success()
end

local FlameShot = Class('ActionNode', require 'data.skill.template.dot')
FlameShot:register('烈焰風暴*傷害') -- 註冊到node_list

function FlameShot:_new(args)
    return self:super():_new(args)
end

function FlameShot:on_pulse()
    Group:new(self.tree_.skill_.source:getObject()):enumUnitsInRange(
        self.tree_:getParam('x'),
        self.tree_:getParam('y'),
        300,
        'IsEnemy'
    ):loop(
        function(this, i)
            self.tree_.skill_.target = Unit(this.units_[i])
            EffectManager:new():add{
                name = "點燃",
                value = {rate={0, 1}, proc={3, 4, 0.5}},
                source = self.tree_.skill_.source,
                target = Unit(this.units_[i]),
            }
            self:showText(self:dealDamage())
        end
    ):remove()
end

function FlameShot:on_finish()
    self.tree_:deleteParam('x')
    self.tree_:deleteParam('y')
    self.tree_.is_finished_ = true
end

local function EnhanceFire(node)
    local start = node.start
    node.start = function(self)
        self.tree_.skill_.proc = {20, 28, 0.5}
        start(self)
    end
end

return {
    name = '烈焰風暴',
    rate = {0, 1}, -- 物理傷害比例, 法術傷害比例
    proc = {18, 24, 0.5},
    scripts = {
        {id = '詠唱', args = {2}},
        {id = '烈焰風暴'},
        {id = '烈焰風暴*傷害', args = {1, 3}}
    },
    decorators = {
        {'烈焰風暴*傷害-火焰強化', EnhanceFire}
    }
}
