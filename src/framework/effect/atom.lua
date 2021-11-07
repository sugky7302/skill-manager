local cls = require 'std.class'("AtomEffect")
local realtionship_table

function cls:_new(type_name, priority)
    return {
        _name_ = type_name,
        _priority_ = priority,
        _effects_ = {}
    }
end

function cls:add(effect_type)
end

function cls:compare(atom)
end

return cls