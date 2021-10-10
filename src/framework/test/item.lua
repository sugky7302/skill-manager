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

        print("****")
        Hero(unit):obtainItem(item)
        item:stack()
        print(unit, "pick up", item:getObject())
        print("****")
    end
)

e:addEvent(
    "單位-丟棄物品",
    "GetTriggerUnit GetManipulatedItem",
    function(_, unit, item)
        print("****")
        Hero(unit):dropItem(Item(item))
        print(unit, "drop", item)
        print("****")
    end
)

-- NOTE: 852008-852013為使用第1~6格物品的指令id - 2020-04-12
-- NOTE: 如果被使用的物品有使用完消失的屬性，會在此事件完成後直接觸發「丟棄物品事件」 - 2020-04-12
e:addEvent(
    "單位-發佈物體目標命令",
    "GetTriggerUnit GetIssuedOrderId GetOrderTarget",
    function(_, unit, order, target)
        print("****")
        print('use')
        if order > 852007 and order < 852014 then
            print(unit, 'use', ej.UnitItemInSlot(unit, order-852008), 'to setting', target)
            Item(ej.UnitItemInSlot(unit, order-852008)):use(Item(target))
        end
        print("****")
    end
)

Group:new():enumUnitsInRange(0, 0, 999999, 'Nil'):loop(
    function(self, i)
        l('單位-拾取物品')(self.units_[i])
        l('單位-丟棄物品')(self.units_[i])
        l('單位-發佈物體目標命令')(self.units_[i])
    end
)
