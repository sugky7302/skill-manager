local AN = require 'framework.behavior.node'
local cls = AN("test")

function cls:_new()
    local this = self:super():new()
    this.a = 5
    return this
end

function cls:getQ()
    return self.a
end

local a = cls:new()
a:getQ()
print(a.a)
print(cls)
print(AN("test"))
print(string.match('', '[.]'))
print(pcall(require, ''))
