-- 適用IAS（攻擊速度）、FCR（施法速度）、FHR（打擊恢復）、FBR（格檔恢復）
local function formula1(act_time, act_speed, base, bonus)
    return math.floor(256 / act_speed * act_time / (base + bonus / 100))
end

local function formula2(base, ed, fix, bonus, decay, crit, element)
    return (base * ( 1 + ed / 100) + fix) * ( 1 + bonus / 100) * (1 - decay / 100) * (crit and 2 or 1) + element
end

-- 防禦在這裡被視為閃避
local function formula3(value_a, value_b, level_a, level_b)
    return value_a / (value_a + value_b) * 2 * level_a / (level_a + level_b)
end

local function formula4(base, bonus)
    return base * (1 + bonus / 100)
end

-- 適用於想要讓該數值趨於設定的期望值
local function formula5(expect, value)
    return expect * value / (expect + value)
end