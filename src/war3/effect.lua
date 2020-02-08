-- 實現EffectTable。

local require = require

local Effect = require 'std.class'('Effect')
local AddModel, DeleteModel, AddTask, DeleteTask, TimerStart, Delete
local IsValid, CheckValid, InitVariables

function Effect:_new(setting, manager)
    return {
        _name_ = setting.name,
        _class_ = setting.class,
        _value_ = setting.value,
        _level_ = 1,
        _period_ = setting.period or setting.time,
        _time_ = setting.time,
        _priority_ = setting.priority or 0,
        _mode_ = setting.mode,
        _icon_ = setting.icon,
        _model_ = setting.model,
        _model_point_ = setting.model_point,
        _global_ = setting.global,
        _max_ = setting.max,
        _keep_after_death_ = setting.keep_after_death or false,
        _manager_ = manager,
        _tasks_ = require 'std.list':new(),
        on_add = setting.on_add,
        on_delete = setting.on_delete,
        on_finish = setting.on_finish,
        on_cover = setting.on_cover,
        on_pulse = setting.on_pulse
    }
end

function Effect:getName()
    return self._name_
end

function Effect:getClass()
    return self._class_
end

function Effect:getPriority()
    return self._priority_
end

function Effect:_remove()
    self:clear()
    self._tasks_:remove()
end

function Effect:clear()
    for _, node in self._tasks_:iterator() do
        Delete(self, node:getData())
    end

    return self
end

function Effect:start(new_task)
    InitVariables(self, new_task)

    if AddTask(self, new_task) then
        self:on_add(new_task)
        -- AddModel(self, new_task)
        TimerStart(self, new_task)
    end

    return self
end

InitVariables = function(self, task)
    task.remaining = task.time or self._time_
    task.period = self._period_
end

AddTask = function(self, new_task)
    if self._tasks_:isEmpty() then
        self._tasks_:push_back(new_task)
        return true
    end

    if self._mode_ == 0 then -- 獨佔模式
        -- effect無法覆蓋或覆蓋失敗
        if not (self.on_cover and self.on_cover(self._tasks_:front(), new_task)) then
            return false
        end

        -- 終止舊的效果
        self:delete(self._tasks_:front())

        -- 替換成新的效果
        self._tasks_:pop_front()
        self._tasks_:push_back(new_task)

        return true
    else -- 共存模式
        -- 比較優先級，新任務較高就覆蓋，都沒有就插入末端
        for i, node in self._tasks_:iterator() do
            if self.on_cover and self.on_cover(node:getData(), new_task) then
                self._tasks_:insert(node, new_task)
                CheckValid(self, i + 1, node:getData())

                -- 因為新效果還沒有實際運行，所以不需要調用self:pause
                return IsValid(i, self._max_)
            end
        end

        -- 因為新效果還沒有實際運行，所以不需要self:pause
        self._tasks_:push_back(new_task)
        return IsValid(self._tasks_:size(), self._max_)
    end
end

function Effect:delete(task)
    Delete(self, task)
    DeleteTask(self, task)
    return self
end

Delete = function(self, task)
    if task.timer then
        task.timer:stop()
    end

    self:on_delete(task)
    -- DeleteModel(self, task)
    return self
end

CheckValid = function(self, index, task)
    if not IsValid(index, self._max_) then
        self:pause(task)
        return false
    end

    return true
end

function Effect:pause(task)
    task.timer:pause()
    self:on_delete(task)
    -- DeleteModel(self, task)
    return self
end

function Effect:resume(task)
    self:on_add(task)
    -- AddModel(self, task)

    if task.timer then
        task.timer:resume()
    else -- 如果是此效果在AddNewTask的共存模式下，沒有建立成功，只有加進列表，這樣就不會有計時器，因此要在這裡補上。
        TimerStart(self, task)
    end

    return self
end

AddModel = function(self, task)
    if not task.target:hasModel(self._model_) then
        task.target:addModel(self._model_)
    end
end

TimerStart = function(self, task)
    print('timer start')
    task.timer =
        require 'war3.timer':new(
        self._period_,
        task.remaining / self._period_,
        function(timer)
            if timer.args[1].on_pulse then
                timer.args[1]:on_pulse(task)
            end

            timer.args[2].remaining = timer.args[2].remaining - timer.args[2].period

            if timer.args[2].remaining <= 0 then
                timer.args[1]:finish(timer.args[2])
            end
        end
    ):start(self, task)
end

function Effect:finish(task)
    self:on_finish(task)
    self:on_delete(task)
    -- DeleteModel(self, task)
    DeleteTask(self, task)
    return self
end

DeleteModel = function(self, task)
    if not task.target:hasModel(self._model_) then
        task.target:deleteModel(self._model_)
    end
end

DeleteTask = function(self, task)
    local i, node = self._tasks_:find(task)

    -- 如果是共存模式，要把暫停的任務恢復
    if self._mode_ == 1 and node.next_ and IsValid(i, self._max_) then
        self:resume(node.next_:getData())
        print('resume ' .. i + 1)
    end

    -- delete會把node刪掉，這樣的話會抓不到next，所以要放在最後面
    self._tasks_:delete(node)

    -- 如果沒有任務就移除效果
    if self._tasks_:isEmpty() then
        self._manager_:delete(task.target, self._name_)
        print('remove effect')
    end
end

IsValid = function(index, max)
    return (max < 1) or (index <= max)
end

return Effect
