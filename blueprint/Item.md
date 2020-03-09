# Item

## 設計目標
- 強化原we的物品功能，並簡化jass的操作函數。
- 作為裝備、消耗品、材料&任務物品、觸發任務的物品的基類。
  - 裝備: 不可疊加、可點擊、拾取後有效果。
  - 材料&任務物品: 可疊加、不可點擊、拾取後沒效果。
  - 消耗品: 可疊加、可點擊、使用後有效果、使用後會消失。
  - 觸發任務的物品: 可疊加、可點擊、拾取後有效果、自動使用(拾取後觸發使用後有效果)、使用後會消失。

## 單一職責
強化原we的物品功能。

## 測試腳本
- 堆疊物品
  - 當英雄獲得物品
  - 調用"堆疊"函數。於此檢查有無相同物品，有的話堆疊
- 拾取裝備
  - 當英雄獲得裝備
  - 添加裝備的屬性於英雄
- 丟棄裝備
  - 當英雄丟棄裝備
  - 移除裝備的屬性於英雄
- 使用裝備
  - 當英雄點擊裝備
  - 以對話框顯示裝備屬性
- 使用藥品
  - 當英雄使用消耗品且此消耗品類型為藥品
  - 對英雄添加藥品的效果，調用"使用"函數
- 英雄施放珠寶的技能
  - 當英雄點擊珠寶對某裝備施放"鑲嵌"技能
  - 記錄該裝備為此珠寶的施放對象
- 使用珠寶
  - 當英雄使用珠寶
  - 如果珠寶特性符合孔特性，則添加珠寶屬性於施放對象，否則返還珠寶

## 依賴
- enhanced_jass as ej

## 成員
- (private) object - 操作對象
- (private) id - 編號，具唯一性
- (private) type - 類型，為一數字
- owner - 擁有者

## 接口

### (static) create
- 輸入: 物品類型, 地點
- 輸出: we物品
- 說明: 本程序會根據物品類型，於該地點新建一個we物品。
- 隱藏細節: X
```
    func create(item_type, loc)
        // 分成兩段式因為直接return會無法新建物品
        item <- ej.CreateItem(ej.decode(item_type), loc.x, loc.y)
        return item
    end func
```

### __ctr__
- 輸入: we物品
- 輸出: 實例
- 說明: 生成一個物品實例。
- 隱藏細節: 每個實例都具唯一性，它會註冊到類別裡。
```
    func __ctr__(item)
        self._object_ <- item
        self._id_ <- ej.H2I(item)
        self._type_ <- ej.Item2S(item)
        self.owner_ <- nil
        將self註冊進Item裡
    end func
```

### __call
- 輸入: we物品
- 輸出: 實例
- 說明: 回傳we物品的實例。
- 隱藏細節: 如果找不到實例會生成一個。
```
    func ()(item)
        return 根據item索引從Item中獲得實例 or a new Item for item
    end func
```

### getObject
- 輸入: X
- 輸出: 操作對象
- 說明: 回傳當前實例的操作對象。
- 隱藏細節: X
```
    func getObject()
        return self.object
    end func
```

### getId
- 輸入: X
- 輸出: 編號
- 說明: 回傳當前實例的唯一編號。
- 隱藏細節: X
```
    func getId()
        return self.id
    end func
```

### getType
- 輸入: X
- 輸出: 類型
- 說明: 回傳當前實例的物品類型。
- 隱藏細節: X
```
    func getType()
        return self.type
    end func
```

### addCharge
- 輸入: 數量
- 輸出: X
- 說明: 增加當前實例的數量。
- 隱藏細節: 會先和當前數量加總再設定，全部都只是操作getCharge和setCharge而已。
```
    func addCharge(count)
        self.setCharge(self.getCharge() + count)
    end func
```

### setCharge
- 輸入: 數量
- 輸出: X
- 說明: 設定當前實例的數量。
- 隱藏細節: 如果數量<=0，會刪除物品。
```
    func setCharge(count)
        count <- max(count, 0)

        if count > 0 then
            the charges of self.object is setted by count
        else
            remove self
        end if
    end func
```

### getCharge
- 輸入: X
- 輸出: 數量
- 說明: 回傳當前實例的數量。
- 隱藏細節: X
```
    func getCharge()
        return the charges of self.object
    end func
```

### stack
- 輸入: X
- 輸出: X
- 說明: 檢查擁有者有無相同物品，有的話會堆疊。
- 隱藏細節: 此函數為空函數，需要子類別實現。
```
    func stack()
    end func
```

### use
- 輸入: X
- 輸出: X
- 說明: 觸發使用此物品會產生的效果。
- 隱藏細節: 此函數為空函數，需要子類別實現。
```
    func use()
    end func
```

