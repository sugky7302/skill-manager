-- 實現EffectTable。

local require = require

local Effect = require 'std.class'('Effect')
local AddModel, DeleteModel, AddTask, DeleteTask, StartTimer
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

function Effect:start(new_task)
    -- InitVariables(new_task)

    if AddTask(self, new_task) then
        self:on_add(new_task)
        -- AddModel(self, new_task)
        StartTimer(self, new_task)
    end

    return self
end

InitVariables = function(task)
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
                return CheckValid(self, i, new_task)
            end
        end

        self._tasks_:push_back(new_task)
        return CheckValid(self, self._tasks_:size(), new_task)
    end
end

CheckValid = function(self, index, task)
    if not IsValid(index, self._max_) then
        self:pause(task)
        return false
    end

    return true
end

StartTimer = function(self, task)
    local Timer = require 'war3.timer'
    task.remaining = task.time or self._time_

    task.timer =
        Timer:new(
        self._period_,
        task.remaining / self._period_,
        function()
            if self.on_pulse then
                self:on_pulse(task)
            end

            task.remaining = task.remaining - self._period_

            if task.remaining <= 0 then
                self:finish(task)
            end
        end
    ):start()
end

function Effect:resume(task)
    self:on_add(task)
    -- AddModel(self, task)
    task.timer:resume()
    return self
end

AddModel = function(self, task)
    if not task.target:hasModel(self._model_) then
        task.target:addModel(self._model_)
    end
end

function Effect:clear()
    for i = #self, 1, -1 do
        self:delete(self[i])
    end

    return self
end

function Effect:delete(task)
    task.timer:stop()
    self:on_delete(task)
    -- DeleteModel(self, task)
    DeleteTask(self, task)
    return self
end

function Effect:finish(task)
    self:on_finish(task)
    self:on_delete(task)
    -- DeleteModel(self, task)
    DeleteTask(self, task)
    return self
end

DeleteTask = function(self, task)
    local i, node = self._tasks_:find(task)

    -- 如果是共存模式，要把暫停的任務恢復
    if self._mode_ == 1 and node.next_ and IsValid(i, self._max_) then
        self:resume(node.next_:getData())
    end

    -- delete會把node刪掉，這樣的話會抓不到next，所以要放在最後面
    self._tasks_:delete(node)
end

IsValid = function(index, max)
    return (max < 1) or (index <= max)
end

function Effect:pause(task)
    task.timer:pause()
    self:on_delete(task)
    -- DeleteModel(self, task)
    return self
end

DeleteModel = function(self, task)
    if not task.target:hasModel(self._model_) then
        task.target:deleteModel(self._model_)
    end
end

return Effect
