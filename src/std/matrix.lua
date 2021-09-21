--[[
Matrix is a math tool to trackle Multi-Dimension calculation.

Member:
    (private) row - the number of matrix row elements
    (private) column - the number of matrix column elements
    (private) values - save matrix values by an array

Function:
    static identity(size) - create an size x size identity matrix
        size - matrix size

    static zero(size) - create an size x size zero matrix
        size - matrix size

    new(self, row1, ...) - create a matrix instance
        self - Class Matrix
        row1 - if ... doesn't exist, it represents row1 is a matrix. Therefore, we use {} constructor.
               if ... exists, it represents row1 is the first row of matrix. Thus, we use () constructor.
        ... - other rows

    __call(self, row1, ...) - the function is the same as above function.

    print(self) - show the matrix formated
        self - matrix instance

    at(self, row, column) - get the element value in Matrix(row, column)
        self - matrix instance
        row - the row position of the element
        column - the column position of the element

    +(self, m) - plus two same size matrices to a new matrix
        self - matrix instance
        m - another matrix

    -(self, m) - minus two same size matrices to a new matrix
        self - matrix instance
        m - another matrix

    *(self, m) - multiple a matrix and a scale or two same size matrices to a new matrix
        self - matrix instance
        m - a scale or a matrix

    /(self, n) -  the matrix divide to a scale to a new matrix
        self - matrix instance
        n - a scale

    =(self, m) - compare whether two matrices are equal
        self - matrix instance
        m - another matrix

    transform(self) - get a new matrix is the transform of the matrix
        self - matrix instance

    inverse(self) - get a new matrix is the inverse of the matrix
        self - matrix instance
]]

local cls = require 'std.class'("Matrix")

local CreateSquareMatrix

function cls.identity(size)
    return cls:new(CreateSquareMatrix(size, function(i)
        if (i == 1) or ((i - 1) % (size + 1) == 0) then
            return 1
        end

        return 0
    end))
end

function cls.zero(size)
    return cls:new(CreateSquareMatrix(size, function()
        return 0
    end))
end

CreateSquareMatrix = function(size, rule)
    local m = {}

    for i = 1, size*size do
        m[i] = rule(i)
    end

    return m
end

return cls