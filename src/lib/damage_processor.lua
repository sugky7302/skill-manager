local DP = require 'std.class'("DamageProcessor")
local AddUp, Parse, Judge, Caculate, Process

function DP:_new()
    if not self._instance_ then
        self._instance_ = {}
    end

    return self._instance_
end

function DP:run(info)
    -- NOTE: 不寫成not(A or B)是因為
    if not Parse(info) and not Judge(info) then
        return nil
    end

    print(info.source .. " attack " .. info.target)

    return "物理", 0
end

return DP
