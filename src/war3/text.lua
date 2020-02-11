local require = require
local ej = require 'war3.enhanced_jass'
local Math = require 'std.math'

local Text = require 'std.class'('Text')
local Init, SetTrace, Scaling, Move, MoveSin, ComputeSinTrace, ComputeMin, UpdateText

-- ex: Text:new{
--     text: 文字,
--     loc: Point(x, y),
--     time: 秒數,
--     mode: 移動模式,
--     font_size: {字體最小值, 字體增大值, 字體最大值},
--     height: {基本高度, 增加高度(沒用填0), 最大高度},
--     offset(可選): Point(x偏移量, y偏移量),
-- }
function Text:_new(data)
    data._invalid_ = false
    data._object_ = ej.CreateTextTag()
    data.init = Init
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
    local displacement = runtime * self.offset
    local loc = self.loc + displacement

    UpdateText(self, loc, ComputeMin(self.font_size, runtime),
               ComputeMin(self.height, runtime))

    loc:remove()
    displacement:remove()
end

ComputeMin = function(x, t)
    return Math.min(x[1] + x[2] * t, x[3])
end

MoveSin = function(self, runtime)
    -- 更新位置
    local displacement = runtime * self.offset
    local loc = self.loc + displacement

    UpdateText(self, loc, ComputeSinTrace(self.font_size, self.time, runtime),
               ComputeSinTrace(self.height, self.time, runtime))

    loc:remove()
    displacement:remove()
end

ComputeSinTrace = function(x, max, t)
    return (x[3]-x[1]) * Math.sin(Math.pi * t / max) + x[1]
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
        require 'war3.timer':new(
        PERIOD,
        (self.time > 0) and self.time / PERIOD or -1,
        function(timer)
            self:update(timer:getRuntime())

            if self._invalid_ then
                self._timer_:stop()
                self:remove()
            end
        end
    ):start()
end

function Text:stop()
    self._invalid_ = true
    return self
end

return Text
