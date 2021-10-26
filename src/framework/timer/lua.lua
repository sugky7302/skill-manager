local coroutine, clock = coroutine, os.clock

local function sleep(t)
    local ntime = clock() + t - 0.001  -- has the error of 0.001 seconds
    repeat until clock() > ntime
end

local function Insert(self, timeout)
    self.end_stamp_ = clock() + timeout

    if (not self._timer_) or coroutine.status(self._timer_) == "dead" then
        self._timer_ = coroutine.create(function(this, t)
            while clock() < this.end_stamp_ do
                sleep(t)
                this.runtime_ = this.runtime_ + t
                this:run()
                
                if this.count_ > 0 then
                    this.count_ = this.count_ - 1
                end

                if this.count_ == 0 then
                    this:remove()
                    break
                else
                    this.end_stamp_ = clock() + t
                end

                if this.remaining_ > 0 then
                    coroutine.yield()
                end
            end
        end)
    end

    coroutine.resume(self._timer_, self, timeout)
end

local function Delete(self)
    -- 如果 remaining > 0，表示調用函數的是暫停，否則是停止
    if self.remaining == 0 then
        self._timer_ = nil
    end
end

local function Now()
    return clock()
end

return {
    Insert = Insert,
    Delete = Delete,
    Now = Now,
}