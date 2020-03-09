# Consumable:Item

## 設計目標
- 實現消耗品、材料、觸發任務的物品的功能。
- 高彈性的使用、堆疊效果，不經過we處理。

## 單一職責
高彈性、簡易地處理可堆疊型物品

## 接口

### stack
- 輸入: X
- 輸出: X
- 說明: 本程序會將同類型的物品疊加起來，並實現滿格拾取的功能。
- 隱藏細節: X
```
    func stack()
        if not self.owner then
            return false
        end if

        for item (all items of self.owner) then
            if item.type == self.type then
                item.addCharge(self.getCharge())
                remove self
                return
            end if
        end for

    end func
```
