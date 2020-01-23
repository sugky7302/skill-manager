local require = require
local SkillTree = require 'skill_tree.skill_tree'
local Event = require 'std.event'
local EventManager = require 'std.event_manager'
local Listener = require 'war3.listener'
local Group = require 'war3.group'
require 'skill_tree.public.init'

local function Main()
    local e = EventManager:new()
    local l = Listener:new(e)
    e:addEvent(
        Event:new(
            '單位-施放技能',
            'GetTriggerUnit',
            function(_, source)
                local sk = SkillTree:new(source)
                sk:append(
                    {
                        'test',
                        'test1'
                    }
                ):run()
            end
        )
    )
    Group:new():enumUnitsInRange(0, 0, 999999, "Nil"):loop(function(self, i)
        l("單位-施放技能")(self.units_[i])
    end)
end

Main()
