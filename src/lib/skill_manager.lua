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
            _data_ = LoadSkillScript(),
        }
    end

    return self._instance_
end

-- NOTE: 資料索引為檔案名，因此data資料夾下的所有腳本不得重名
LoadSkillScript = function()
    local skill_decorator = require 'lib.skill_decorator':new()
    local ipairs = ipairs
    local scripts, data = {}

    for _, folder in ipairs(skill_script_path) do
        data =
            select(
            2,
            xpcall(
                require,
                debug.traceback,
                Table.concat({'data.skill.', folder, '.init'})
            )
        )

        -- 註冊裝飾器
        for _, skill in pairs(data) do
            if skill.decorators then
                for _, t in ipairs(skill.decorators) do
                    skill_decorator:setDecorator(t[1], t[2])
                end
            end
        end

        Table.merge(scripts, data)
    end

    return scripts
end

function SkillManager:get(skill_name, source, target)
    local skill = Table.copy(self._data_[skill_name])
    skill.source = source
    skill.target = target or source

    return skill
end

function SkillManager:query(skill_name)
    return self._data_[skill_name]
end

return SkillManager
