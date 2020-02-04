local require = require
local EffectManager = require 'std.class'('EffectManager')

local LoadTemplate, AddNewTask, NameComparison, GetList, GetEffect, CompareEffectAssociation
local effect_script_path = {
    'public'
}

function EffectManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _templates_ = LoadTemplate(),
            _user_data_ = {}
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

    -- 搜尋效果，有的話對該效果建立新的任務
    AddNewTask(self, setting)

    return self
end

AddNewTask = function(self, setting)
    local effect = self:find(setting.target, setting.name)

    if effect then
        effect:start(setting)
    else
        effect = GetEffect(self, setting.name)
        if CompareEffectAssociation(GetList(self, setting.target), effect) then
            GetList(self, setting.target):append(effect:start(setting))
        end
    end
end

GetEffect = function(self, name)
    return require 'war3.effect':new(self._templates_[name], self)
end

CompareEffectAssociation = function()
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
    if not self._user_data_[target] then
        self._user_data_[target] = require 'std.array':new()
    end
    return self._user_data_[target]
end

NameComparison = function(a, b)
    return a:getName() == b
end

return EffectManager
