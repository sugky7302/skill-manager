local cls = require 'std.class'("Skill")

function cls:_new()
    return {
        _info_ = require 'framework.skill.info':new(id),
    }
end

return cls