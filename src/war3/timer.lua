local require = require
local ej = require 'war3.enhanced_jass'

local PERIOD, INSTRUCTION_COUNT = 0.001, 10
local timer_queue = {}
local current_frame, end_frame, order_queue_index = 0, 0, 0
local ExecuteOrder, ProcessOrder, Insert, Delete, ComputePauseFrame

local function StartTimer()
    ej.TimerStart(
        ej.CreateTimer(),
        PERIOD * INSTRUCTION_COUNT,
        true,
        function()
            -- 上一幀的命令隊列尚未處理完
            if order_queue_index > 0 then
                current_frame = current_frame - 1
            end

            end_frame = end_frame + INSTRUCTION_COUNT

            for i = current_frame, end_frame do
                current_frame = current_frame + 1
                ExecuteOrder()
            end
        end
    )
end

ExecuteOrder = function()
    local order_queue = timer_queue[current_frame]
    if not order_queue then
        order_queue_index = 0
        return false
    end

    local order
    for i = order_queue_index + 1, #order_queue do
        -- 記錄當前命令索引，如果沒處理完還能在下一迴圈處理
        order_queue_index = i

        order = order_queue[i]
        if order then
            ProcessOrder(order)
        end

        order_queue[i] = nil
    end

    -- 所有命令都做完了，命令索引要指回第一個
    order_queue_index = 0

    -- 必須所有引用都清除，lua才會釋放記憶體
    timer_queue[current_frame] = nil
    order_queue = nil
end

ProcessOrder = function(order)
    -- 記錄已執行次數，方便計算總執行時間
    -- NOTE: 放在執行函數前面是因為函數裡調用getRuntime的時間才會正確；放在執行函數後面，會getRuntime會少一個循環。
    order.run_count_ = order.run_count_ + 1

    order:run()

    -- 如果執行run時，order將自身所有資料刪除，這裡直接跳出避免報錯
    if not order.count_ then
        return false
    end

    -- 如果count_是-1，表示無窮迴圈，因此不用遞減
    if order.count_ > 0 then
        order.count_ = order.count_ - 1
    end

    if order.count_ == 0 then
        order:remove()
        return false
    end

    -- 處理指令暫停的情況
    if order.pause_frame_ > 0 then
        return false
    end

    Insert(order, order.frame_)
end

-- NOTE: 不直接使用order.frame_的原因是
--       恢復計時器的動作中，插入的frame是剩餘時間。
Insert = function(order, frame)
    if order.count_ == 0 then
        return false
    end

    local end_stamp = current_frame + frame
    order.end_stamp_ = end_stamp

    if not timer_queue[end_stamp] then
        timer_queue[end_stamp] = {} -- 這裡不能用弱引用表，不然會丟失
        setmetatable(timer_queue[end_stamp], timer_queue[end_stamp])
    end

    -- 使用變數提高插入指令的程式碼的閱讀性
    local order_queue = timer_queue[end_stamp]
    order_queue[#order_queue + 1] = order
end

Delete = function(order)
    local order_queue = timer_queue[order.end_stamp_]
    if not order_queue then
        return false
    end

    -- NOTE: 使用table.remove才能完整刪除，
    --       只設定為nil反而會讓數組中斷。
    for k, v in ipairs(order_queue) do
        if v == order then
            table.remove(order_queue, k)
            return true
        end
    end
end

local function Frame(time)
    local math = math
    return math.max(math.floor(time / PERIOD) or 1, 1)
end

local function Now()
    return current_frame
end

local Timer = require 'std.class'('Timer')

function Timer:_new(timeout, count, action)
    return {
        frame_ = Frame(timeout),
        count_ = count, -- 循環次數必須>0，-1定義為永久，0定義為結束
        end_stamp_ = 0, -- 提前結束會用到結束點
        pause_frame_ = 0, -- 恢復時會需要剩餘時間
        run_count_ = 0,
        run = action,
        args = nil -- 儲存外部參數
    }
end

function Timer:start(...)
    self.args = {...}
    Insert(self, self.frame_)
    return self
end

function Timer:stop()
    -- 外部停止需要把計時器從隊列中刪除
    Delete(self)
    self:remove()
end

function Timer:pause()
    -- 處在正常狀態才能執行以下動作
    if self.pause_frame_ == 0 then
        ComputePauseFrame(self)
        print('remain ' .. self.pause_frame_ .. ' ms and ' .. self.count_ .. ' times')

        -- 外部暫停需要把計時器從隊列中刪除
        Delete(self)
    end

    return self
end

ComputePauseFrame = function(self)
    self.pause_frame_ = self.end_stamp_ - Now()

    -- NOTE: 如果pause_frame=0表示pause是計時器動作內自己執行的，而這樣的含意為下一次執行要暫停，因此要計算下一次的時間戳記。
    if self.pause_frame_ == 0 and (self.count_ == -1 or self.count_ - 1 > 0) then
        self.pause_frame_ = self.pause_frame_ + self.frame_
    end
end

function Timer:resume()
    if self.pause_frame_ > 0 then
        Insert(self, self.pause_frame_)
    end

    -- pause_frame要歸零，不然中心計時器會認為還在暫停中而不會將命令插到下個時序
    self.pause_frame_ = 0

    return self
end

function Timer:getRuntime()
    return PERIOD * self.frame_ * self.run_count_
end

-- 初始化中心計時器
StartTimer()

return Timer
