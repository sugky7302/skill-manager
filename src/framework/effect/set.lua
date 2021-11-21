--[[
    EffectType is used to define a variaty of effects.
    Besides, dealing with a relationship of other's Effect Types is its another important task.
--]]

local require = require
local cls = require 'std.class'("EffectSet")
local AddTask

function cls:_new(data)
    return {
        _object_ = nil,
        _tasks_ = require 'std.list':new(),
        _name_ = data.name,
        _type_ = data.type,
        _priority_ = data.priority,
        _mode_ = data.mode,
        _max_ = data.max,  -- 運行最大數量
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

function cls:subscribe(name, callback)
    self._listener_:add(name, nil, callback)
    return self
end

function cls:add(effect)
    if self._tasks_:isEmpty() then
        self._tasks_:push_back(effect)
        OnAdd(self, effect)
        return self
    end

    if self._mode_ == 0 then -- 獨佔模式
        -- effect覆蓋成功才執行匿名函數
        self._listener_.onTick("效果-覆蓋", self._tasks_:front(), effect, function()
            -- 終止舊的效果
            self:delete(self._tasks_:front())

            -- 替換成新的效果
            self._tasks_:pop_front()
            self._tasks_:push_back(effect)
            OnAdd(self, effect)
        end)
    else -- 共存模式
        -- 比較優先級，新任務較高就覆蓋，都沒有就插入末端
        -- TODO: 不曉得要怎麼做
        for i, node in self._tasks_:iterator() do
            self._listener_.onTick("效果-覆蓋", node:getData(), effect, function()
                self._tasks_:insert(node, effect)
            end)
                CheckValid(self, i + 1, node:getData())

                -- 因為新效果還沒有實際運行，所以不需要調用self:pause
                return IsValid(i, self._max_)
            end
        end

        -- 因為新效果還沒有實際運行，所以不需要self:pause
        self._tasks_:push_back(effect)
        return IsValid(self._tasks_:size(), self._max_)
    end
    
    return self
end

OnAdd = function(self, effect)
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
end

function cls:clear()
    for _, node in self._tasks_:iterator() do
        node:getData()._timer_:stop()
    end
end

function cls:pause()
    for _, node in self._tasks_:iterator() do
        node:getData()._timer_:pause()
    end
end

function cls:resume()
    for _, node in self._tasks_:iterator() do
        node:getData()._timer_:resume()
    end
end

return cls