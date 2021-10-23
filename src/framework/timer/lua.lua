local coroutine, clock = coroutine, os.clock

local function sleep(t)
    local ntime = clock() + t - 0.001  -- 有0.001的誤差
    repeat until clock() > ntime
end

local function Insert(self, timeout)
    self.end_stamp_ = clock() + timeout
    self._timer_ = coroutine.create(function(this, t)
        if this.count_ == -1 then
            while true do
                sleep(t)
                this.runtime_ = this.runtime_ + t
                self:run()
                coroutine.yield()
                if this.remaining_ > 0 then
                    break
                end
            end
        else
            for i = 1, this.count_ do
                sleep(t)
                self:run()
                this.runtime_ = this.runtime_ + t
                coroutine.yield()
                if this.remaining_ > 0 then
                    break
                end
            end
        end
    end)

    coroutine.resume(self._timer_, self, timeout)
end

local function Delete(self)
    -- 利用remaining被當作中止條件，任意設定一個數使迴圈停止
    self.remaining_ = 1
    coroutine.resume(self._timer_)
    self.remaining_ = 0
end

local function Now()
    return clock()
end

return {
    Insert = Insert,
    Delete = Delete,
    Now = Now,
}