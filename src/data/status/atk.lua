local require = require
local ej = require 'war3.enhanced_jass'
local skill = require 'std.ascii'.decode('Abun')

return {
    name = '無法攻擊',
    set = function(self, status)
        if status then
            ej.UnitAddAbility(self.object_, skill)
        else
            ej.UnitRemoveAbility(self.object_, skill)
        end
    end,
}
