local require = require
local ej = require 'war3.enhanced_jass'
local ascii = require 'std.ascii'
local EventManager = require 'lib.event_manager'
local Listener = require 'war3.listener'
local Attribute = require 'lib.attribute'

local Unit = require 'std.class'("Unit")
local SetSkillStatus

function Unit:_new(unit)
    local instance = {
        _object_ = unit,
        _id_ = ej.H2I(unit),
        _type_ = ascii.encode(ej.U2Id(unit)),
        _attribute_ = Attribute:new(unit),
        owner_ = ej.getPlayer(unit),  -- HACK: 暫時隨便寫一個，等到Player類別確定再改
    }

    -- 將實例綁在類別上，方便呼叫
    self[unit] = instance

    return instance
end

function Unit:_remove()
    ej.RemoveUnit(self._object_)
    Unit[self._object_] = nil
end

function Unit:__call(unit)
    return Unit[unit] or self:new(unit)
end

-- NOTE: 直接return ej.CreateUnit不會回傳單位
function Unit.create(unit_type, player, loc)
    local new_unit = ej.CreateUnit(player, ascii.decode(unit_type), loc.x, loc.y, 0)
    return new_unit
end

function Unit:getObject()
    return self._object_
end

function Unit:getId()
    return self._id_
end

function Unit:getType()
    return self._type_
end

function Unit:getLoc()
    return ej.GetUnitX(self._object_), ej.GetUnitY(self._object_)
end

function Unit:isAlive()
    return self:getAttribute("生命") > 0.3
end

function Unit:isHero()
    return ej.IsUnitHero(self._object_, ej.UNIT_TYPE_HERO)
end

function Unit:enableSkill(skill)
    return SetSkillStatus(self, skill, true)
end

function Unit:disableSkill(skill)
    return SetSkillStatus(self, skill, false)
end

SetSkillStatus = function(self, skill, status)
    ej.SetPlayerAbilityAvailable(self.owner_, ascii.decode(skill), status)
    return self
end

function Unit:hasSkill(skill)
    return ej.GetUnitAbilityLevel(self._object_, ascii.decode(skill)) > 0
end

function Unit:addSkill(skill, lv)
    skill = ascii.decode(skill)
    lv = lv or 1

    ej.UnitAddAbility(self._object_, skill)
    ej.SetUnitAbilityLevel(self._object_, skill, lv)
    return self
end

function Unit:removeSkill(skill)
    ej.UnitRemoveAbility(self._object_, ascii.decode(skill))
    return self
end

function Unit:resetSkill(skill)
    local lv = ej.GetUnitAbilityLevel(self._object_, ascii.decode(skill))
    self:removeSkill(skill):addSkill(skill, lv)
    return self
end

function Unit:addAttribute(key, value)
    self._attribute_:add(key, value)
    return self
end

function Unit:setAttribute(key, value)
    self._attribute_:set(key, value)
    return self
end

function Unit:getAttribute(key)
    return self._attribute_:get(key)
end

function Unit:listen(event_name)
    Listener:new(EventManager:new())(event_name)(self._object_)
    return self
end

function Unit:eventDispatch(event_name, ...)
    EventManager:new():dispatch(event_name, self, ...)
    return self
end

return Unit
