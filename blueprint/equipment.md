# Equipment:Item

## 設計目標
- 設計鑲嵌、雕刻、附魔、共振、超魔等精鍊裝備的功能，每一道步驟的成功率都會驟降。
- 根據不同材料，會產生不同的副作用。越強的材料有越強的副作用。
- 根據不同材料，自動生成對應類型的插孔，並記錄該鑲孔對被鑲嵌的寶石的條件和特殊效果。
- 提供優良、簡易的接口供外部使用。

## 定義
實現高自由度的裝備功能，並提供高度封裝的接口供外部使用。

## 成員
- (private) attribute - 記錄物品屬性

## 依賴
- Attribute

## 接口

### __ctr__
- 輸入: we物品
- 輸出: 實例
- 說明: 生成一個裝備實例。
- 細節: X
```
    func __ctr__(item)
        self <- a new Item instance
        self._attribute_ <- a new Atrribute instance
    end func
```

### __call
- 輸入: we物品
- 輸出: 實例
- 說明: 回傳we裝備的實例。
- 隱藏細節: 如果找不到實例會生成一個。
```
    func ()(item)
        return 根據item索引從Equipment中獲得實例 or a new Equipment for item
    end func
```

### attributes

### addAttribute

### deleteAttribute

### obtain

### drop

