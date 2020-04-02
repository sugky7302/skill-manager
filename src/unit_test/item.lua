local e = require 'lib.event_manager':new()
local l = require 'war3.listener':new(e)
local ej = require 'war3.enhanced_jass'
local Equipment = require 'war3.equipment'
local Consumable = require 'war3.consumable'
local Item = require 'war3.item'
local Hero = require 'war3.hero'
local Group = require 'war3.group'


e:addEvent(
    "單位-拾取物品",
    "GetTriggerUnit GetManipulatedItem",
    function(_, unit, item)
        local level = ej.GetItemLevel(item)

        if level == 0 then
            item = Equipment(item)
        elseif level == 1 then
            item = Consumable(item)
        else
            item = Item(item)
        end

        Hero(unit):obtainItem(item)
        item:stack()
        print("****")
        print(unit)
        print("pick up")
        print(item)
        print("****")
    end
)

e:addEvent(
    "單位-丟棄物品",
    "GetTriggerUnit GetManipulatedItem",
    function(_, unit, item)
        Hero(unit):dropItem(Item(item))
        print("****")
        print(unit)
        print("drop")
        print(item)
        print("****")
    end
)

e:addEvent(
    "單位-使用物品",
    "GetManipulatedItem",
    function(_, item)
        Item(item):use()
        print("****")
        print("use")
        print(item)
        print("****")
    end
)

Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-拾取物品')(self.units_[i])
        l('單位-丟棄物品')(self.units_[i])
        l('單位-使用物品')(self.units_[i])
    end
)
