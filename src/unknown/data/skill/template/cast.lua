local require = require
local Text = require 'war3.text'
local concat = table.concat

local SpellStart = require 'std.class'('ActionNode', require 'lib.skill_tree.node')
SpellStart:register('詠唱') -- 註冊到node_list
local IsBroken, Cast

function SpellStart:_new(args)
    local instance = self:super():new()
    instance.time_ = args[1]
    return instance
end

function SpellStart:start()
    self.remaining_ = self.time_
    self.ui_ =
        Text:new(
        {
            text = concat {'*', self.time_, 's*'},
            loc = {self.tree_.skill_.source:getLoc()},
            time = self.time_,
            mode = 'fix',
            font_size = {0.022, 0, 0.022},
            height = {80, 0, 80}
        }
    ):start()
    Cast(self.tree_.skill_.source, true)
end

function SpellStart:run()
    if self.remaining_ <= 0 then
        Cast(self.tree_.skill_.source, false)
        self:success()
        return
    end

    self.remaining_ = self.remaining_ - self.tree_.period_
    self.ui_:setText(concat {'*', string.format('%.1f', self.remaining_), 's*'})

    if IsBroken(self) then
        self.tree_.is_finished_ = false
        self:clear()
        Cast(self.tree_.skill_.source, false)
    end

    self:running()
end

function SpellStart:clear()
    self.ui_:stop()
end

Cast = function(source, status)
    source:setStatus('無法攻擊', status)

    if not source:hasStatus '移動施法' then
        source:setStatus('無法轉身', status)
        source:setStatus('無法移動', status)
    end
end

IsBroken = function(self)
    return false
end

return SpellStart
