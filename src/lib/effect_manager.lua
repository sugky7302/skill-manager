local require = require
local EffectManager = require 'std.class'('EffectManager')
local EFFECT_RELATION = require 'data.effect.relational_table'

local LoadTemplate, AddNewTask, NameComparison, GetList, GetEffect, CompareEffectAssociation
local effect_script_path = {
    'public'
}

function EffectManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _templates_ = LoadTemplate(),
            _effects_ = {},
        }
    end

    return self._instance_
end

LoadTemplate = function()
    local Table = require 'std.table'
    local scripts, data = {}

    for _, folder in ipairs(effect_script_path) do
        data = select(2, xpcall(require, debug.traceback, Table.concat({'data.effect.', folder, '.init'})))

        Table.merge(scripts, data)
    end

    return scripts
end

function EffectManager:add(setting)
    -- 沒有名字或目標都不算是正確的配置表
    if not (setting.name and setting.target) then
        return self
    end

    -- 無此效果直接跳出
    if not self:getTemplate(setting.name) then
        return self
    end

    if not CompareEffectAssociation(self, setting) then
        return self
    end

    -- 搜尋效果，有的話對該效果建立新的任務
    AddNewTask(self, setting)
    return self
end

-- TODO: 新效果要一一與舊效果比對，根據原子狀態關係表處理關係
-- 共存(0):添加新效果不會影響舊效果 ; 1:舊效果在，無法添加新效果 ; 2:新效果加入並暫停，待舊效果結束後恢復 ; 3:添加新效果，舊效果暫停 ; 互斥(4):添加新效果，舊效果移除 ; 消融(5):新舊效果都移除
CompareEffectAssociation = function(self, setting)
    local status
    for _, effect in GetList(self, setting.target):iterator() do
        status = EFFECT_RELATION[effect:getClass()][self:getTemplate(setting.name).class]

        if status == 0 then
        elseif status == 1 then
        end
    end
    return true
end

AddNewTask = function(self, setting)
    local effect = self:find(setting.target, setting.name)

    if effect then
        effect:start(setting)
    else
        GetList(self, setting.target):append(GetEffect(self, setting.name):start(setting))
    end
end

GetEffect = function(self, name)
    return require 'war3.effect':new(self._templates_[name], self)
end

function EffectManager:find(target, name)
    local index, effect = GetList(self, target):exist(name, NameComparison)
    return index and effect or nil
end

function EffectManager:delete(target, name)
    local effect = self:find(target, name)

    if effect then
        effect:clear()
        GetList(self, target):erase(name, NameComparison)
    end

    return self
end

GetList = function(self, target)
    if not self._effects_[target] then
        self._effects_[target] = require 'std.array':new()
    end
    return self._effects_[target]
end

NameComparison = function(a, b)
    return a:getName() == b
end

function EffectManager:getTemplate(name)
    return self._templates_[name]
end

return EffectManager
