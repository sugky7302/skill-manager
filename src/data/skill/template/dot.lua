local require = require

local Dot = require 'std.class'('ActionNode', require 'data.skill.template.one_shot')

function Dot:_new(args)
    local node = self:super():_new()
    node._period_ = args[1]
    node._count_ = args[2]
    return node
end

function Dot:start()
    self.period_ = self._period_
    self.count_ = self._count_
end

function Dot:run()
    if self.period_ <= 0 then
        self:on_pulse()
        self.count_ = self.count_ - 1
        self.period_ = self._period_
    end

    if self.count_ < 1 then
        self:on_finish()
        self:success()
        return
    end

    self.period_ = self.period_ - self.tree_.period_
    self:running()
end

function Dot:on_pulse()
    self:dealDamage()
end

function Dot:on_finish()
end

return Dot
