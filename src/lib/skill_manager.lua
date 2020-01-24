local require = require
local SkillManager = require 'std.class'('SkillManager')
local Table = require 'std.table'

local LoadSkillScript
local skill_script_path = {
    'public'
}

function SkillManager:_new()
    if not self._instance_ then
        self._instance_ = {
            _data_ = LoadSkillScript()
        }
    end

    return self._instance_
end

-- NOTE: 資料索引為檔案名，因此data資料夾下的所有腳本不得重名
LoadSkillScript = function()
    local scripts = {}
    for _, folder in ipairs(skill_script_path) do
        Table.merge(
            scripts,
            select(2, xpcall(require, function(err) print(err) end, Table.concat({'data.skill.', folder, '.init'})))
        )
    end

    return scripts
end

function SkillManager:get(skill_name, source, target)
    local skill = Table.copy(self._data_[skill_name])
    skill.source = source
    skill.target = target or source
    return skill
end

return SkillManager
