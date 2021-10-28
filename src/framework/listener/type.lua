local ej = require 'war3.enhanced_jass'

local ID = {
    ['單位-死亡'] = ej.EVENT_UNIT_DEATH,  -- GetDyingUnit, GetKillingUnitBJ
    ['單位-受到傷害'] = ej.EVENT_UNIT_DAMAGED,  -- GetEventDamageSource
    ['單位-被選取'] = ej.EVENT_UNIT_SELECTED,  -- GetEnumUnit、GetFilerUnit
    ['單位-升級'] = ej.EVENT_UNIT_HERO_LEVEL, -- GetLevelingUnit
    ['單位-學習技能'] = ej.EVENT_UNIT_HERO_SKILL,  -- GetLearningUnit
    ['單位-施放技能'] = ej.EVENT_UNIT_SPELL_CAST,  -- GetSpellAbilityUnit, GetSpellTargetUnit
    ['單位-拾取物品'] = ej.EVENT_UNIT_PICKUP_ITEM,  -- GetManipulatingUnit
    ['單位-丟棄物品'] = ej.EVENT_UNIT_DROP_ITEM,  -- GetManipulatingUnit
    ['單位-使用物品'] = ej.EVENT_UNIT_USE_ITEM,  -- GetManipulatingUnit
    ['單位-發佈無目標命令'] = ej.EVENT_UNIT_ISSUED_ORDER,  -- GetOrderedUnit
    ['單位-發佈點目標命令'] = ej.EVENT_UNIT_ISSUED_POINT_ORDER,  -- GetOrderedUnit
    ['單位-發佈物體目標命令'] = ej.EVENT_UNIT_ISSUED_TARGET_ORDER,  -- GetOrderedUnit, GetOrderTargetUnit(限於單位命令)
    ['單位-開始腐化'] = ej.EVENT_UNIT_DECAY,  -- GetDecayingUnit
    ['單位-被裝載'] = ej.EVENT_UNIT_LOADED, -- GetLoadedUnit, GetTransportUnitBJ
    ['單位-召喚'] = ej.EVENT_UNIT_SUMMON, -- GetSummonedUnit, GetSummoningUnit
    ['單位-改變所有者'] = ej.EVENT_UNIT_CHANGE_OWNER, -- GetChangingUnit
    ['單位-注意到攻擊目標'] = ej.EVENT_UNIT_ACQUIRED_TARGET, -- GetEventTargetUnit
    ['單位-獲得攻擊目標'] = ej.EVENT_UNIT_TARGET_IN_RANGE, -- GetEventTargetUnit
    ['建築-開始製造'] = ej.EVENT_UNIT_TRAIN_START, -- GetTrainedUnit
    ['建築-取消製造'] = ej.EVENT_UNIT_TRAIN_CANCEL, -- GetTrainedUnit
    ['建築-完成製造'] = ej.EVENT_UNIT_TRAIN_FINISH, -- GetTrainedUnit
    ['建築-開始升級'] = ej.EVENT_UNIT_UPGRADE_START,  -- GetConstructingStructure
    ['建築-取消升級'] = ej.EVENT_UNIT_UPGRADE_CANCEL,  -- GetCancelledStructure
    ['建築-完成升級'] = ej.EVENT_UNIT_UPGRADE_FINISH, -- GetConstructedStructure
    ['科技-開始研究'] = ej.EVENT_UNIT_RESEARCH_START, -- GetResearchingUnit
    ['科技-取消研究'] = ej.EVENT_UNIT_RESEARCH_CANCEL, -- GetResearchingUnit
    ['科技-完成研究'] = ej.EVENT_UNIT_RESEARCH_FINISH, -- GetResearchingUnit
    ['英雄-開始復活'] = ej.EVENT_UNIT_HERO_REVIVE_START, -- GetRevivableUnit, GetRevivingUnit
    ['英雄-取消復活'] = ej.EVENT_UNIT_HERO_REVIVE_CANCEL, -- GetRevivableUnit, GetRevivingUnit
    ['英雄-完成復活'] = ej.EVENT_UNIT_HERO_REVIVE_FINISH, -- GetRevivableUnit, GetRevivingUnit
    ['商店-出售單位'] = ej.EVENT_UNIT_SELL,  --GetSellingUnit(販賣者), GetSoldUnit(被販賣的)
    ['商店-出售物品'] = ej.EVENT_UNIT_SELL_ITEM,  -- GetBuyingUnit, GetSellingUnit
    ['商店-抵押物品'] = ej.EVENT_UNIT_PAWN_ITEM,  --GetSellingUnit
    ['測試'] = 4,
    ['對話框-被點擊'] = 92, -- GetClickedDialog GetClickedButton
}

local function Register(trg, event_name, event_source)
    local event_type = string.match(event_name, '[^-]+')

    -- NOTE: 請在這加入該類型事件的註冊方法函數！！
    if event_type == '單位' or event_type == '建築' or event_type == "商店" or
       event_type == '科技' or event_type == "英雄"  then
        ej.TriggerRegisterUnitEvent(trg, event_source, ID[event_name])
    elseif event_type == '對話框' then
        ej.TriggerRegisterDialogEvent(trg, event_source)
    elseif event_type == '測試' then
        ej.TriggerRegisterTimerEvent(trg, 0, false)
    end
end

local OBJECT = {
    ["單位"] = "GetTriggerUnit",
    ["建築"] = "GetTriggerUnit",
    ["科技"] = "GetTriggerUnit",
    ["英雄"] = "GetTriggerUnit",
    ["對話框"] = "GetClickedDialog",
    ["玩家"] = "GetTriggerPlayer",
    ["破壞物"] = "GetTriggerDestructable",
}

return {
    ID = ID,
    Register = Register,
    OBJECT = OBJECT,
}