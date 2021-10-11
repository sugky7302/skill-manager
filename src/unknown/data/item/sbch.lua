return {
    equip = function(self)
        print("obtain")
    end,
    drop = function(self)
        print("drop")
    end,
    use = function(self, target)
        target:addCharge(5)
        print(target:getCharge())
    end
}
