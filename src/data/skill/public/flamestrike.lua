local require = require
local View = require 'war3.view'
local Unit = require 'war3.unit'
local Text = require 'war3.text'
local ej = require 'war3.enhanced_jass'
local Group = require 'war3.group'
local Point = require 'std.point'
local concat = table.concat


local SpellStart = require 'std.class'('ActionNode', require 'lib.skill_tree.node')
SpellStart:register('詠唱') -- 註冊到node_list
local IsBroken, StartCasting, StopCasting

function SpellStart:_new(args)
    local instance = self:super():new()
    instance.time_ = args[1]
    return instance
end

function SpellStart:start()
    StartCasting(self.tree_.skill_.source)
    self.remaining_ = self.time_
    self.ui_ =
        Text:new(
        {
            text = concat {'*', self.time_, 's*'},
            loc = {self.tree_.skill_.source:getLoc()},
            time = self.time_,
            mode = 'fix',
            font_size = {0.022, 0, 0.022},
            height = {80, 0, 80}
        }
    ):start()
end

StartCasting = function(source)
    source:addSkill('Abun')

    if source:getAttribute "移動施法" == 0 then
        source:setAttribute("轉身速度", 0)
        ej.SetUnitPropWindow(source:getObject(), 0)
    end
end

function SpellStart:run()
    if self.remaining_ <= 0 then
        StopCasting(self.tree_.skill_.source)
        self:success()
        return
    end

    self.remaining_ = self.remaining_ - self.tree_.period_
    self.ui_:setText(concat {'*', string.format('%.1f', self.remaining_), 's*'})

    if IsBroken(self) then
        self.tree_.is_finished_ = true
        self:clear()
        StopCasting(self.tree_.skill_.source)
    end

    self:running()
end

function SpellStart:clear()
    self.ui_:stop()
end

StopCasting = function(source)
    source:removeSkill('Abun')

    if source:getAttribute "移動施法" == 0 then
        source:setAttribute("轉身速度", 0.5)
        ej.SetUnitPropWindow(source:getObject(), ej.GetUnitDefaultPropWindow(source:getObject()))
    end
end

IsBroken = function(self)
    return false
end


local FlameStrike = require 'std.class'('ActionNode', require 'lib.skill_tree.node')
FlameStrike:register('烈焰風暴') -- 註冊到node_list

function FlameStrike:_new()
    return self:super():new()
end

function FlameStrike:run()
    local x, y = ej.GetLocationX(self.tree_.skill_.target), ej.GetLocationY(self.tree_.skill_.target)
    View:new('Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl', x, y, 0):start()
    View:new('Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl', x, y, 2):start()

    Group:new():enumUnitsInRange(x, y, 250, 'Nil'):loop(
        function(this, i)
            require 'lib.damage_processor':new().run(self.tree_.skill_, self.tree_.skill_.source, Unit(this.units_[i]))
        end
    ):remove()
    self.tree_.is_finished_ = true
    self:success()
end

local function EnhanceFire(node)
    local start = node.start
    node.start = function(self)
        self.tree_.skill_.proc = {200, 200, 0.5}
        start(self)
    end
end

return {
    file_key = '烈焰風暴',
    name = '烈焰風暴',
    rate = {0, 1}, -- 物理傷害比例, 法術傷害比例
    proc = {18, 24, 0.5},
    scripts = {
        {id = '詠唱', args = {2}},
        {id = '烈焰風暴'}
    },
    decorators = {
        {'烈焰風暴-火焰強化', EnhanceFire}
    }
}
