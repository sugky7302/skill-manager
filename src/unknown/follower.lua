local require = require
local ej = require 'war3.enhanced_jass'

local Follower = require 'std.class'("Follower", require 'war3.unit')
local SetLifeTime

function Follower:_new(unit, owner)
    local follower = self:super():_new(unit)
    follower._owner_ = owner
    return self
end

function Follower:__call(unit)
    return self:super().__call(self, unit)
end

-- NOTE: 沒填時間表示無限
function Follower:create(follwer_type, owner, loc, time)
    local follower = self:new(self:super().create(follwer_type, owner, loc))
    SetLifeTime(follower, time)
    ej.SetUnitAnimation(follower._object_, "birth")
    return self
end

SetLifeTime = function(follower, time)
    if not time then
        return
    end

    ej.setLifeTime(follower._object_, time)
end

return Follower
