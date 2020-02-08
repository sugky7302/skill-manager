local require = require
local EffectManager = require 'std.class'('EffectManager')
local EFFECT_RELATION = require 'data.effect.relational_table'

local LoadTemplate, AddNewTask, NameComparison, GetList, GetEffect, CompareEffectAssociation, RemoveEffect
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

    print(setting.name .. " will be added to Unit" .. setting.target)

    -- if not CompareEffectAssociation(self, setting) then
    --     return self
    -- end

    -- 搜尋效果，有的話對該效果建立新的任務
    AddNewTask(self, setting)
    return self
end

-- 新效果要一一與舊效果比對，根據原子狀態關係表處理關係
-- 共存(0):添加新效果不會影響舊效果 ; 互斥(1):比較優先級，優先級低的會移除
-- 消融(2):新舊效果都移除 ; 4[暫無]:新效果加入並暫停，待舊效果結束後恢復 ; 5[暫無]:添加新效果，舊效果暫停
CompareEffectAssociation = function(self, setting)
    local list = GetList(self, setting.target)
    local template, status

    for i, effect in list:iterator() do
        print("[" .. i .."] " .. effect:getName() .. "->" .. setting.name)
        template = self:getTemplate(setting.name)
        status = EFFECT_RELATION[effect:getClass()][template.class] or 0  -- 找不到視同共存

        -- status=0 -> 不做任何動作
        if status == 1 then
            if effect:getPriority() < (template.priority or 0) then
                RemoveEffect(list, effect)
            else
                return false
            end
        elseif status == 2 then
            RemoveEffect(list, effect)
            return false
        end
    end

    return true
end

RemoveEffect = function(list, effect)
    list:erase(effect)
    effect:remove()
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
    GetList(self, target):erase(name, NameComparison)
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
