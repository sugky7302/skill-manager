-- Timer是子節點調用running會重複執行，調用success或fail則會前往下個子節點，直到所有子節點完成或收到break命令才會跳出。
local cls = require 'framework.behavior.node.composite'("Timer")

function cls:_new(args)
    local this = self:super():new()
    this._timer_ = require 'framework.timer':new(args[1], 1, function(t) t.args[1]:run() end)
end

function cls:success()
    self:super().success(self)  -- 調用子節點的finish函數

    self._index_ = self._index_ + 1
    if self._index_ <= #self._children_ then
        self:run()
    else
        self:super():super().success(self)
    end
end

function cls:fail()
    self:success()
end

function cls:running()
    self._is_child_running_ = true
    self._timer_:start(self)
end

function cls:Break()
    self:super().success(self)  -- 調用子節點的finish函數
    self:super():super().success(self)
end

return cls
