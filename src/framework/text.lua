local require = require
local ej = require 'war3.enhanced_jass'
local Math = require 'std.math'
local Point = require 'std.point'
local Timer = require 'war3.timer'

local Text = require 'std.class'('Text')
local Init, SetTrace, Scaling, Move, MoveSin, ComputeSinTrace, ComputeMin, UpdateText, IsExpired

-- ex: Text:new{
--     text: 文字,
--     loc: {x, y},
--     time: 秒數,
--     mode: 移動模式,
--     font_size: {字體最小值, 字體增大值, 字體最大值},
--     height: {基本高度, 增加高度(沒用填0), 最大高度},
--     offset(可選): {距離, 角度},
--     on_pulse(可選): 每個週期都會調用的函數,
-- }
function Text:_new(data)
    data._invalid_ = false
    data._object_ = ej.CreateTextTag()
    data.init = Init
    data.loc = Point:new(data.loc[1], data.loc[2])

    -- NOTE: 如果輸入random會隨機弧度；若輸入角度會自動轉換成弧度，這樣方便使用者填入，畢竟正常都用角度。
    if data.offset then
        local angle = (data.offset[2] == 'random') and ej.GetRandomReal(0, 2 * Math.pi) or Math.rad(data.offset[2])
        data.offset = Point:new(data.offset[1] * Math.cos(angle), data.offset[1] * Math.sin(angle))
    end

    SetTrace(data)

    return data
end

Init = function(self)
    local TIME_FADE = 0.3

    ej.SetTextTagText(self._object_, self.text, self.font_size[1])
    ej.SetTextTagPos(self._object_, self.loc.x, self.loc.y, self.height[1])

    -- 設置結束點、淡出動畫時間
    ej.SetTextTagPermanent(self._object_, self.time > 0 and false or true)
    ej.SetTextTagLifespan(self._object_, self.time)
    ej.SetTextTagFadepoint(self._object_, TIME_FADE)
end

SetTrace = function(self)
    if self.mode == 'fix' then -- 原地縮放
        self.update = Scaling
    elseif self.mode == 'move' then -- 移動
        self.update = Move
    elseif self.mode == 'sin' then -- 正弦移動
        self.update = MoveSin
    end
end

Scaling = function(self, runtime)
    ej.SetTextTagText(self._object_, self.text, ComputeMin(self.font_size, runtime))
end

Move = function(self, runtime)
    -- 更新位置
    local displacement = self.offset * runtime
    local loc = self.loc + displacement

    UpdateText(self, loc, ComputeMin(self.font_size, runtime), ComputeMin(self.height, runtime))

    loc:remove()
    displacement:remove()
end

ComputeMin = function(x, t)
    return Math.min(x[1] + x[2] * t, x[3])
end

MoveSin = function(self, runtime)
    -- 更新位置
    local displacement = self.offset * runtime
    local loc = self.loc + displacement

    UpdateText(
        self,
        loc,
        ComputeSinTrace(self.font_size, self.time, runtime),
        ComputeSinTrace(self.height, self.time, runtime)
    )

    loc:remove()
    displacement:remove()
end

ComputeSinTrace = function(x, max, t)
    return (x[3] - x[1]) * Math.sin(Math.pi * t / max) + x[1]
end

UpdateText = function(self, loc, font_size, height)
    ej.SetTextTagText(self._object_, self.text, font_size)
    ej.SetTextTagPos(self._object_, loc.x, loc.y, height)
end

function Text:_remove()
    ej.DestroyTextTag(self._object_)
    self.loc:remove()

    if self.offset then
        self.offset:remove()
    end
end

function Text:start()
    local PERIOD = 0.04

    self:init()

    self._timer_ =
        Timer:new(
        PERIOD,
        (self.time > 0) and self.time / PERIOD or -1,
        function(timer)
            -- NOTE: 一定要放在update前面，不然on_pulse如果有更新文字之類的動作，本次週期不會更新。
            if self.on_pulse then
                self:on_pulse(timer)
            end

            self:update(timer:getRuntime())

            if IsExpired(self, timer.count_) then
                self._timer_:stop()
                self:remove()
            end
        end
    ):start()

    return self
end

IsExpired = function(self, count)
    return self._invalid_ or count == 1
end

function Text:stop()
    self._invalid_ = true
    return self
end

function Text:setText(text)
    self.text = text
    return self
end

return Text
