local SkillDecorator = require 'std.class'("SkillDecorator")

function SkillDecorator:_new()
    if not self._instance_ then
        self._instance_ = {}
    end

    return self._instance_
end

function SkillDecorator:append(key, decorator_name)
    local decorator_list = self:get(key)

    -- 如果之前有註冊過相同的裝飾器，就不理它
    for _, name in ipairs(decorator_list) do
        if name == decorator_name then
            return self
        end
    end

    decorator_list[#decorator_list+1] = decorator_name
    return self
end

function SkillDecorator:wrap(target, node)
    local decorator_list = self:get(target.source)

    for _, name in ipairs(decorator_list) do
        if node:getName() == string.match(name, '[^-]+') then
            self:getDecorator(name)(node)
        end
    end

    return self
end

function SkillDecorator:get(key)
    if not self[key] then
        self[key] = {}
    end

    return self[key]
end

function SkillDecorator:getDecorator(name)
    return self[name]
end

function SkillDecorator:setDecorator(name, decorator_func)
    self[name] = decorator_func
    return self
end

return SkillDecorator
