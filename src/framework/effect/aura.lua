local require = require
local cls = require 'std.class'("AuraEffect")

-- selector{region, range, condition}
function cls:_new(data, args)
    assert(args, "請添加參數")
    local selector = {
        args.region or "circle",
        {x=0, y=0},
        args.range or 100,
        data.target}

    local filter = {args.filter, data.target}

    return {
        _units_ = require 'framework.group':new():select(selector):filter(filter),
        _effects_ = require 'framework.effect.set':new(data),
        _timer_ = require 'framework.timer':new(1, -1, function() end),
    }
end