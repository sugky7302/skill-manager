local ej = require 'war3.enhanced_jass'

return {
    IsEnemy = function(enumer, filter)
        return ej.GetUnitState(enumer, ej.UNIT_STATE_LIFE) > 0.3 and ej.IsUnitEnemy(enumer, ej.GetOwningPlayer(filter))
    end,
    IsAlly = function(enumer, filter)
        return ej.GetUnitState(enumer, ej.UNIT_STATE_LIFE) > 0.3 and ej.IsUnitAlly(enumer, ej.GetOwningPlayer(filter))
    end,
    IsHero = function(enumer, filter)
        return ej.IsUnitType(enumer, ej.UNIT_TYPE_HERO)
    end,
    IsUnit = function(enumer, filter)
        return not (ej.IsUnitType(enumer, ej.UNIT_TYPE_HERO))
    end
}