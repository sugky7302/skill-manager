local require = require
local skill_manager = require 'lib.skill_manager':new()
local Math = require 'std.math'

local DP = require 'std.class'('DamageProcessor')
local AddUp, Parse, Judge, Calculate, Process, IsDodge, IsPenetrated
local IsCrit, GetAttack, GetDefense, DealDamage, GetRatio

local TYPE_A = {}
local TYPE_B = {}
local TYPE_C = {}
local TYPE_D = {}

function DP:_new()
    if not self._instance_ then
        self._instance_ = {}
    end

    return self._instance_
end

function DP.run(name, source, target)
    local event = {
        name = name,
        source = source,
        target = target,
        value = 0,  -- 傷害值
        rate = nil,  -- 物理傷害和法術傷害的占比。左邊是物理、右邊是法術
        proc = 0,  -- 法術攻擊力的倍率係數
        is_crit = 0,  -- 是否暴擊。暴擊=1，正常=0
        is_blk = 1,  -- 是否穿透。格擋=1，正常=0
        status = 0  -- 狀態判定。判定過程可能出現閃避、穿透等特殊現象，0=正常、1=穿透、2=閃避、4=格擋、8=暴擊
    }

    if not Parse(event) then
        return nil
    end

    if not Judge(event) then
        return nil
    end

    Calculate(event)
    Process(event)

    return event.status, event.value
end

Parse = function(event)
    if event.source == event.target then
        return false
    end

    if event.name == '普通攻擊' then
        event.rate = {1, 0} -- 物理傷害和法術傷害的占比。左邊是物理、右邊是法術
        return true
    end

    local skill = skill_manager:query(event.name)
    if not skill then
        return false
    end

    event.rate = skill.rate or {0, 1} -- 物理傷害和法術傷害的占比。左邊是物理、右邊是法術
    event.proc = skill.proc or 1 -- 法術攻擊力的倍率係數
    return true
end

Judge = function(event)
    if IsDodge(event.source, event.target) then
        event.status = 2
        return false
    end

    if IsPenetrated(event.source, event.target) then
        event.is_blk = 0
        event.status = 1
    end

    if IsCrit(event.source, event.target) then
        event.is_crit = 1
        event.status = event.status + 8
    end

    return true
end

IsDodge = function(source, target)
    local p = Math.rand(0, 100)
    local hit = GetRatio(source:getAttribute('命中'), source:getAttribute("等級"), 60, 50)
    local dodge = GetRatio(target:getAttribute('閃避'), target:getAttribute("等級"), 60, 50)

    if dodge > hit then
        return p < 80 + 100 * (dodge - hit)
    elseif dodge == hit then
        return p < 51
    else
        return p >= 80 + 100 * (hit - dodge)
    end
end

IsPenetrated = function(source, target)
    local pnt = GetRatio(source:getAttribute('穿透'), source:getAttribute("等級"), 60, 50)
    local blk = GetRatio(target:getAttribute('格擋'), target:getAttribute("等級"), 60, 50)

    return pnt > blk
end

IsCrit = function(source, target)
    local crt = GetRatio(source:getAttribute('暴擊'), source:getAttribute("等級"), 60, 50)
    local act = GetRatio(target:getAttribute('韌性'), target:getAttribute("等級"), 60, 50)
    return crt > act
end

GetRatio = function(x, y, k, b)
    return x / (x + k * y + b)
end

Calculate = function(event)
    local atk, def = GetAttack(event.source, event.rate, event.proc), GetDefense(event.target, event.rate)
    event.value =
        Math.bound(
        0.05 * atk,
        (event.is_crit + 1) * (atk - event.is_blk * def),
        0.95 * event.target:getAttribute('生命上限')
    ) - event.target:getAttribute('護盾')
end

GetAttack = function(source, rate, proc)
end

GetDefense = function(target, rate)
end

AddUp = function(unit, attribute_list)
    local sum = 1
    for _, name in ipairs(attribute_list) do
        sum = sum + unit:getAttribute(name)
    end

    return sum
end

Process = function(event)
    if event.value > 0 then
        DealDamage(event.target, event.value)
    end

    -- NOTE: 不用add的原因是value = 傷害 - 護盾 => -value = 護盾 - 傷害 = 剩餘護盾量
    --       每次都要計算護盾量。因為如果value > 0，表示破盾，max(0, -value) = 0，剛好將護盾值設為0；
    --       如果value < 0，表示還有護盾，max(0, -value) = 剩餘護盾量，也剛好將護盾值設為剩餘護盾量。
    event.target:setAttribute('護盾', Math.max(0, -event.value))

    -- 儲存最後傷害，有些技能會用到
    event.target:setAttribute('最後造成的傷害', event.value)
end

DealDamage = function(target, value)
    if value < target:getAttribute('生命') then
        target:addAttribute('生命', -value)
    else
        require 'war3.enhanced_jass'.removeUnit(target:getObject())
    end
end

return DP
