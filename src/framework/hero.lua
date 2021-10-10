local require = require
local SkillManager = require 'lib.skill_manager'
local Hero = require 'std.class'("Hero", require 'war3.unit')
local AddStatus

function Hero:_new(unit)
    local hero = self:super():_new(unit)
    hero._items_ = {false, false, false, false, false, false}
    AddStatus(hero)
    return hero
end

AddStatus = function(hero)
    hero._status_:set("移動施法", false)
end

function Hero:__call(unit)
    return self:super().__call(self, unit)
end

function Hero:decorateSkill(decorator_name)
    SkillManager:new():append(self, decorator_name)
    return self
end

-- target必須是Unit或其子類別
function Hero:spell(skill_name, target, period)
    return SkillManager:new():get(skill_name, self, target, period):run()
end

function Hero:items()
    local i = 0
    return function()
        -- NOTE: j = [0,5] 是因為i = [1,6]且每次調用items都要遞增索引，
        --       如果j = [1,6]會一直卡在第一個物品無法遞增。
        for j = i, #self._items_-1 do
            i = i + 1

            if self._items_[i] then
                return i, self._items_[i]
            end
        end

        return nil
    end
end

function Hero:obtainItem(item)
    for i = 1, #self._items_ do
        if not self._items_[i] then
            self._items_[i] = item
            item.owner_ = self
            item:obtain()
            return true
        end
    end

    return false
end

function Hero:dropItem(item)
    for i = 1, #self._items_ do
        if self._items_[i] == item then
            self._items_[i] = false
            item:drop()
            item.owner_ = nil
            return true
        end
    end

    return false
end

return Hero
