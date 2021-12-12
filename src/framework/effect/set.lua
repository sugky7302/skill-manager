--[[
    EffectSet is used to define a variaty of effects.
    Besides, dealing with a relationship of other's Effect tags is its another important task.
--]]
local require = require
local cls = require "std.class"("EffectSet")
local Run, Stop, Pause, Resume

function cls:_new(data)
    local Pass = function()
        return true
    end
    return {
        _tasks_ = require "std.list":new(),
        _name_ = data.name,
        _states_ = data.states or {},  -- 可以有很多狀態，每個狀態類似於標籤
        _priority_ = data.priority,
        _mode_ = data.mode,
        _max_ = data.max or 99999, -- 運行最大數量
        _keep_after_death_ = data.keep_after_death or false,
        -- 效果於各個狀態的觸發函數
        -- NOTE: 由於listener是callback，使用上會有很多問題，因此不使用它來統整
        on = {
            add = data.on.add or Pass,
            delete = data.on.delete or Pass,
            finish = data.on.finish or Pass,
            cover = data.on.cover or Pass,
            pulse = data.on.pulse or Pass
        }
    }
end

function cls:_remove()
    self._tasks_:remove()
end

function cls:states()
    return self._states_
end

function cls:add(task)
    if self._tasks_:isEmpty() then
        self._tasks_:push_back(task)
        Run(self, task)
        return true
    end

    if self._mode_ == 0 then -- 獨佔模式
        -- effect覆蓋成功才執行匿名函數
        if self.on["cover"](self._tasks_:front(), task) then
            Stop(self, self._tasks_:front())
            self._tasks_:push_back(task)
            Run(self, task)

            return true
        end

        return false
    else -- 共存模式
        -- 比較優先級，新任務較高就覆蓋，都沒有就插入末端
        for i, node in self._tasks_:iterator() do
            if self.on["cover"](node:getData(), task) then
                self._tasks_:insert(node, task)

                -- 暫停不在執行區的效果
                if (i+1 > self._max_) then
                    Pause(self, node)
                end

                return true
            end
        end

        self._tasks_:push_back(task)
        if (self._tasks_:size() <= self._max_) then
            Run(self, task)
            return true
        end

        return false
    end
end

Run = function(self, task)
    self.on["add"](task.target, task.value, task.source)
    task.timer = require "framework.timer":new(
        task.time,
        task.time / task.period,
        function(t)
            self.on['pulse'](task.target, task.value, task.source)

            if t.count == 1 then
                self.on['finish'](task.target, task.value, task.source)
                Stop(self, task)
            end
        end
    ):start()
end

function cls:stop()
    for _, node in self._tasks_:iterator() do
        Stop(self, node:getData())
    end
end

Stop = function(self, task)
    self.on["delete"](task.target, task.value, task.source)
    if task.timer then
        task.timer:stop()
    end

    local i, node = self._tasks_:find(task)

    -- 如果是共存模式，要把暫停的任務恢復
    if self._mode_ == 1 and node.next_ and (i <= self._max_) then
        Resume(self, node.next_:getData())
    end

    -- delete會把node刪掉，這樣的話會抓不到next，所以要放在最後面
    self._tasks_:delete(node)
end

function cls:resume()
    for _, node in self._tasks_:iterator() do
        Resume(self, node:getData())
    end
end

Resume = function(self, task)
    if task.timer then
        task.timer:resume()
    else  -- 如果共存模式下新增效果會遇到沒有建立成功的情況，這樣就不會有計時器，因此要在這裡補上。
        Run(self, task)
    end
end

function cls:pause()
    for _, node in self._tasks_:iterator() do
        Pause(self, node:getData())
    end
end

Pause = function(self, task)
    self.on["delete"](task.target, task.value, task.source)
    if task.timer then
        task.timer:pause()
    end
end

function cls:getRemaining()
    if self.mode == 0 then
        return self._tasks_:front()._timer_.remaining_
    end

    local remaining = 0
    local max = math.max
    
    for i, node in self._tasks_:iterator() do
        if i > self._max_ then
            break
        end

        remaining = max(remaining, node:getData()._timer_.remaining_)
    end

    return remaining
end

function cls:setRemaining(v)
    if self.mode == 0 then
        self._tasks_:front()._timer_.remaining_ = v
        return self
    end
    
    for i, node in self._tasks_:iterator() do
        if i > self._max_ then
            break
        end

        node:getData()._timer_.remaining_ = v
    end

    return self
end

return cls
