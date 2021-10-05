--[[
  Rune is an most important and complicated system and a powerful feature of the game.

  Required:
    red_black_tree

  Member:
    _slot_ - save all runes which are mounted on the object

  Function:
    new(self) - create a new rune instance
      self - class
      return - instance

    mount(self, id, level) - add a jass item into the slot
      self - instance
      id - item's id
      level - item's level
      return - attribute name, value

    demount(self, index) - remove the index-th item from the slot
      self - instance
      index - the index of the item in the slot
      return - item's id

    iterator(self) - traverse slot
      self - instance
--]]

local require = require
local cls = require 'std.class'("Rune")

function cls:_new(path)
    local status, retval = pcall(require, path)  -- 搜不到會回傳 false
    return {
        _package_ = status and retval,
        _slot_ = require 'std.list':new()
    }
end

function cls:iterator()
    return self._slot_:iterator()
end

function cls:mount(id, level)
    if not self._package_ then
        return
    end

    local data = self._package_:read(id)
    if not data then
        return
    end

    local v = {id, data[1], data[2](level)}
    self._slot_:push_back(v)
    return v[2], v[3]
end

function cls:demount(index)
    for i, node in self._slot_:iterator() do
        if i == index then
            local id = node:getData()[1]
            self._slot_:delete(node)
            return id
        end
    end
end

return cls