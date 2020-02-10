local require = require
local ej = require 'war3.enhanced_jass'
local Math = require 'std.math'

local Text = require 'std.class'('Text')
local Init, SetMode, Scaling, MoveUp, MoveDown, MoveLeft, MoveRight, MoveSin, MoveCos

-- ex: Text:new{
--     text: 文字,
--     loc: Point(x, y),
--     time: 秒數,
--     mode: 移動模式,
--     font_size: {字體最小值, 字體增大值, 字體最大值},
--     height: {基本高度, 增加高度(沒用填0)},
--     offset(可選): Point(x偏移量, y偏移量),
-- }
function Text:_new(data)
    data._invalid_ = false
    data._object_ = ej.CreateTextTag()
    data.init = Init
    SetMode(data)

    return data
end

Init = function(self)
    local TIME_FADE = 0.3

    ej.SetTextTagText(self._object_, self.text, self.font_size[1])
    ej.SetTextTagPos(self._object_, self.loc.x, self.loc.y, self.font_size[1] * self.height[1])

    -- 設置結束點、淡出動畫時間
    ej.SetTextTagPermanent(self._object_, self.time > 0 and false or true)
    ej.SetTextTagLifespan(self._object_, self.time)
    ej.SetTextTagFadepoint(self._object_, TIME_FADE)
end

SetMode = function(self)
    if self.mode == "fix" then  -- 原地縮放
        self.update = Scaling
    elseif self.mode == "up" then  -- 向上移動
        self.update = MoveUp
    elseif self.mode == "down" then  -- 向下移動
        self.update = MoveDown
    elseif self.mode == "left" then  -- 向左移動
        self.update = MoveLeft
    elseif self.mode == "right" then  -- 向右移動
        self.update = MoveRight
    elseif self.mode == "sin" then  -- 正弦移動
        self.update = MoveSin
    elseif self.mode == "cos" then  -- 餘弦移動
        self.update = MoveCos
    end
end

Scaling = function(self)
end

MoveUp = function(self)
end

MoveDown = function(self)
end

MoveLeft = function(self)
end

MoveRight = function(self)
end

MoveSin = function(self)
end

MoveCos = function(self)
end

function Text:_remove()
    ej.DestroyTextTag(self._object_)
    self.loc:remove()

    if self.offset then
        self.offset:remove()
    end
end

function Text:start()
    local PERIOD = 0.1

    self:init()

    self._timer_ =
        require 'war3.timer':new(
        PERIOD,
        (self.time > 0) and self.time / PERIOD or -1,
        function(timer)
            if self.update then
                self:update()
            end

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
