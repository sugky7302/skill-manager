--[[
  Timer is an enhanced extension of jass timer.

  Required:
    math
    enhanced_jass

  Member:
    frame - 幀數
    count - 循環次數
    end_stamp - 結束時間戳
    pause_frame - 暫停時間戳
    run_count - 已循環次數
    run - 動作函數
    args - 外部參數列表

  Function:
    new(timeout, count, action) - create a new timer object
      timeout - 循環週期
      count - 循環次數。如果次數有限，必須 >0；如果無窮次數，要設定為 -1。
      action - 動作函數

    start(...) - start timer
    ... - 想要在動作函數裡執行的參數

    stop() - stop timer

    pause() - pause timer

    resume() - resume timer

    getRuntime() - get the time which the timer has been run.
--]]

local require = require
local math = math
local core = select(2, xpcall(require, function() return require 'framework.timer.lua' end, 'framework.timer.war3'))
local ComputeRemaining, Now

local Timer = require 'std.class'('Timer')

function Timer:_new(timeout, count, action)
    return {
        timeout_ = timeout,
        count_ = math.ceil(count), -- 循環次數必須>0，-1定義為永久，0定義為結束
        end_stamp_ = 0, -- 提前結束會用到結束點
        remaining_ = 0, -- 恢復時會需要剩餘時間
        runtime_ = 0,
        run = action,
        args = nil -- 儲存外部參數
    }
end

function Timer:start(...)
    self.args = {...}
    core.Insert(self, self.timeout_)
    return self
end

function Timer:stop()
    -- 外部停止需要把計時器從隊列中刪除
    core.Delete(self)
    self:remove()
end

function Timer:pause()
    -- 處在正常狀態才能執行以下動作
    if self.remaining_ == 0 then
        ComputeRemaining(self)

        -- 外部暫停需要把計時器從隊列中刪除
        core.Delete(self)
    end

    return self
end

ComputeRemaining = function(self)
    self.remaining_ = self.end_stamp_ - Now()

    -- NOTE: (循環計時器) 如果 remaining=0 表示pause是計時器動作內部調用的，
    --       這樣的含意即下一次執行要暫停，因此要計算下一次的時間戳記。
    if self.remaining_ == 0 and (self.count_ == -1 or self.count_ - 1 > 0) then
        self.remaining_ = self.timeout_
    end
end

Now = function()
    return core.Now()
end

function Timer:resume()
    if self.remaining_ > 0 then
        core.Insert(self, self.remaining_)
    end

    -- pause_frame要歸零，不然中心計時器會認為還在暫停中而不會將命令插到下個時序
    self.remaining_ = 0

    return self
end

return Timer
