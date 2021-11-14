--[[
    EffectType is used to define a variaty of effects.
    Besides, dealing with a relationship of other's Effect Types is its another important task.
--]]

local require = require
local cls = require 'std.class'("EffectSet")

function cls:_new(data)
    return {
        _object_ = nil,
        _tasks_ = require 'std.list':new(),
        _name_ = data.name,
        _type_ = data.type,
        _priority_ = data.priority,
        _mode_ = data.mode,
        _max_ = data.max,
        _keep_after_death_ = data._keep_after_death_,
        _listener_ = require 'framework.listener':new(),
    }
end

function cls:_remove()
    self._tasks_:remove()
end

function cls:type()
    return self._type_
end

function cls:add(effect)
    self._tasks_:push_back(effect)
    self._listener_:onTick("效果-新增", self._object_, effect.value, effect.source)
    effect.timer_ = require 'framework.timer':new(
        effect.time,
        effect.time/effect.period,
        function(t)
            local this = t.args[0]
            this._listener_:onTick("效果-觸發", this._object_, effect.value, effect.source)

            if t.count == 1 then
                this._listener_:onTick("效果-完成", this._object_, effect.value, effect.source)
            end
        end
    ):start(self)
    return self
end

function cls:clear()
    for _, node in self._tasks_:iterator() do
        node:getData()._timer_:stop()
    end
end

return cls