return {
    add = function(self, recipe, product)
        self[recipe] = product
        return self
    end,
    find = function(self, recipe)
        return self[recipe]
    end
}