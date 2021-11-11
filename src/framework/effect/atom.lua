local cls = require 'std.class'("AtomEffect")
local realtionship_table

function cls:_new(type_name)
    return {
        _name_ = type_name,
        prev_ = nil,  -- 借用linking list的概念把同類型的效果串起來，當在針對類型做動作時也會比較好處理。
        next_ = nil,
    }
end

function cls:name()
    return self._name_
end

-- 與該效果類型建立連結
function cls:add(effect_type)
    self.next_, effect_type.prev_ = effect_type, self
    return self
end

function cls:compare(atom)
end

return cls