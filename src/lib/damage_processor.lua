local DP = require 'std.class'("DamageProcessor")

function DP:_new()
    if not self._instance_ then
        self._instance_ = {
            _is_running_ = false,
        }
    end

    return self._instance_
end

function DP:run(info)
    if self._is_running_ then
        return
    end

    print(info.source .. " attack " .. info.target)

    return "物理", 0
end

return DP
