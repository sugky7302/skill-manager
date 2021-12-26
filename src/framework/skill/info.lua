--[[
Only allow to load war3 data into here, not write the data back because it would cover its data to all of the war3 skill instance.
--]]

local require, pairs = require, pairs
local ej = require 'war3.enhanced_jass'
local cls = require 'std.class'("SkillInfo")

function cls:_new(owner, id)
    local this = require('jass.slk').ability[id]
    assert(this, "無效的技能ID，請重新輸入。")

    this.owner = owner
    this.id = id
    this.level = 1

    return this
end

function cls:setOption(option)
    for k, v in pairs(option) do
        self[k] = v
    end

    return self
end

function cls:levelUp(lv)
    return self:setLevel(self.level + lv)
end

function cls:setLevel(lv)
    self.level = lv
    ej.SetUnitAbilityLevel(self.owner, self.level)
    return self
end

return cls