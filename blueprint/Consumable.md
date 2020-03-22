# Consumable:Item

## 設計目標
- 實現消耗品、材料、觸發任務的物品的功能。
- 高彈性的使用、堆疊效果，不經過we處理。

## 單一職責
高彈性、簡易地處理可堆疊型物品

## 接口

### __call
- 輸入: we物品
- 輸出: 實例
- 說明: 回傳we消耗品的實例。
- 隱藏細節: 如果找不到實例會生成一個。
```
    func ()(item)
        return 根據item索引從Consumable中獲得實例 or a new Consumable for item
    end func
```

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
