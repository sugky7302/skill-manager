local timers = {}

local tbinsert = table.insert
local tbremove = table.remove
local ipairs = ipairs
local xpcall = xpcall
local traceback = debug.traceback

local co_create = coroutine.create
local co_running = coroutine.running
local co_resume = coroutine.resume
local co_yield = coroutine.yield

---you can replace this with your clock function
local clock = os.clock

local function insert_timer(sec, fn)
    local expiretime = clock() + sec
    local pos = 1

    -- 搜尋位置
    for i, v in ipairs(timers) do
        if v.expiretime > expiretime then
            break
        end
        pos = i+1
    end

    local context = { expiretime =expiretime, fn = fn}
    tbinsert(timers, pos, context)
    return context
end

local co_pool = setmetatable({}, {__mode = "kv"})  -- key & value自動回收

local function coresume(co, ...)
    local ok, err = co_resume(co, ...)
    if not ok then
        error(traceback(co, err))
    end
    return ok, err
end

local function routine(fn)
    local co = co_running()
    while true do
        fn()
        co_pool[#co_pool + 1] = co  -- 因為co_pool是kv，所以要一直添加co到co_pool裡
        fn = co_yield()  -- 等待resume
    end
end

local M = {}

function M.async(fn)
    local co = tbremove(co_pool)  -- 刪除最後一個元素並回傳
    if not co then
        co = co_create(routine)
    end
    local _, res = coresume(co, fn)
    if res then  -- 回傳yield傳來的值
        return res
    end
    return co
end

---@param seconds integer @duration in seconds，decimal part means millseconds
---@param fn function @ timeout callback
function M.timeout(seconds, fn)
    return insert_timer(seconds, fn)
end

---coroutine style
---@param seconds integer @duration in seconds，decimal part means millseconds
--[[
  原理：
    因為協程一次只能一個，所以利用 coroutine.running 獲得調用它的協程。
    接著先添加復甦時間到時間隊列，再把當前協程掛起。
    最後等到時間隊列執行到這個函數的時候就會恢復當前協程。
--]]
    function M.sleep(seconds)
    local co, status = co_running()
    insert_timer(seconds, function()
        co_resume(co)
    end)
    print(status)
    return co_yield()
end

function M.remove(ctx)
    ctx.remove = true
end

function M.update()
    while #timers >0 do
        local timer = timers[1]
        if timer.expiretime <= clock() then
            tbremove(timers,1)
            if not timer.remove then
                local ok, err = xpcall(timer.fn, traceback)
                if not ok then
                    print("timer error:", err)
                end
            end
        else
            break
        end
    end
end



timer = M

local function co3()
    print("coroutine3 start",os.clock())
    timer.sleep(5.5)
    print("coroutine3 5.5 second later",os.clock())
    print("coroutine3 end")
end

--coroutine style timer
timer.async(function()
    print("coroutine1 start",os.time())
    timer.sleep(2)
    print("coroutine1 2 second later",os.time())
    timer.async(co3)
    print("coroutine1 end")
end)

timer.async(function()
    print("coroutine2 start",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time() )
    print("coroutine2 end")
end)

--callback style timer
local stime = os.time()
timer.timeout(1.5,function()
    print("timer expired", os.time() - stime)
end)

--remove a timer
local ctx = timer.timeout(5,function()
    error("this timer should not expired")
end)
timer.remove(ctx)

print("main thread noblock")

while true do
    timer.update()
end

print("Completed!")