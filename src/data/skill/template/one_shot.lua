local require = require
local Combat = require 'war3.combat'

local OneShot = require 'std.class'('ActionNode', require 'lib.skill_tree.node')

function OneShot:_new()
    return self:super():new()
end

function OneShot:run()
    self:dealDamage()
    self:success()
end

function OneShot:dealDamage()
    Combat(self.tree_.skill_, self.tree_.skill_.source, self.tree_.skill_.target)
end

return OneShot
