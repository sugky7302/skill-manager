for var_1, ..., var_n in <explist> do <block> end

<=>

do 
    local _f, _s, _var = <explist>  -- 這時的f只是引用explist的函數，到底下才調用
    while true do 
        local var_1, ..., var_n = _f(_s, _var)  -- 這裡才調用_f
        _var = var_1
        if _var == nil then
            break
        end
        <block>
    end
end

-- 自己寫的iterator是使用閉包實現，因此如果要直接調用，必須寫成self:iterator()()才對
