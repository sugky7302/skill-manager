local ej = require 'war3.enhanced_jass'
local PERIOD, INSTRUCTION_COUNT = 0.001, 10
local timer_queue = {}
local current_frame = 1
local ExecuteOrder, ProcessOrder, Insert, Delete, Frame

local function Start()
    ej.TimerStart(ej.CreateTimer(), PERIOD * INSTRUCTION_COUNT, true,function()
        -- NOTE: 捨棄end_frame。原來會用到是因為Moe master是用while做，while執行速度比較慢，
        --       因此我採用for去處理，這就不需要end_frame了。 - 2020-02-26
        -- NOTE: 反正只是要循環10次，不用特別用current_frame和end_frame，反而麻煩。 - 2020-02-26
        for i = 1, INSTRUCTION_COUNT do
            ExecuteOrder()

            -- NOTE: 如果掉幀，則frame就不會+1，而order_queue_index還保留最後做完的索引，
            --       很自然就達到補幀的效果。 - 2020-02-26
            current_frame = current_frame + 1
        end
    end)
end

ExecuteOrder = function()
    local order_queue = timer_queue[current_frame]
    if not order_queue then
        return false
    end

    -- NOTE: 由於pairs會跳過value=nil的索引，因此只要每次完成都設定為nil，掉幀時就能從有值的索引開始。 - 2020-02-26
    for i, order in pairs(order_queue) do
        if order then
            ProcessOrder(order)
        end

        order_queue[i] = nil
    end

    -- 必須所有引用都清除，lua才會釋放記憶體
    timer_queue[current_frame] = nil
    order_queue = nil
end

ProcessOrder = function(order)
    -- 記錄已執行次數，方便計算總執行時間
    -- NOTE: 放在執行函數前面是因為函數裡讀取runtime才會正確；放在執行函數後面，runtime會少掉這次執行的時間。
    order.runtime_ = order.runtime_ + (order.remaining_ > 0 and order.remaining_ or order.timeout_)

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
    if order.remaining_ > 0 then
        return false
    end

    Insert(order, order.timeout_)
end

-- NOTE: 不直接使用order.frame_的原因是
--       恢復計時器的動作中，插入的frame是剩餘時間。
Insert = function(order, t)
    if order.count_ == 0 then
        return false
    end

    local end_stamp = current_frame + Frame(t)
    order.end_stamp_ = end_stamp * PERIOD

    if not timer_queue[end_stamp] then
        timer_queue[end_stamp] = {} -- 這裡不能用弱引用表，不然會丟失
        setmetatable(timer_queue[end_stamp], timer_queue[end_stamp])
    end

    -- 使用變數提高插入指令的程式碼的閱讀性
    local order_queue = timer_queue[end_stamp]
    order_queue[#order_queue + 1] = order
end

Delete = function(order)
    local order_queue = timer_queue[Frame(order.end_stamp_)]
    if not order_queue then
        return false
    end

    -- NOTE: 使用table.remove才能完整刪除，
    --       只設定為nil反而會讓數組中斷。
    -- NOTE: 由於table.remove會將空位補滿，導致order_queue_index跳過補空位的那個動作。
    --       例如我刪掉第6個，第7個會補到第6個的位置，結果order_queue_index跳到了7，就造成掉幀的現象。
    --       ExecuteOrder改採pairs遍歷，它會跳過值=nil的索引，這樣就保留原本for迴圈要達到的功能。 - 2020-02-26
    for k, v in ipairs(order_queue) do
        if v == order then
            order_queue[k] = nil
            return true
        end
    end
end

Frame = function(time)
    local math = math
    return math.max(math.floor(time / PERIOD), 1)
end

local function Now()
    return current_frame * PERIOD
end

Start()

return {
    Insert = Insert,
    Delete = Delete,
    Now = Now,
}