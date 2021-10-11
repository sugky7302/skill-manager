local function a(...)
    for k, v in ipairs{...} do
        print(k, v)
    end
end

a("a", 1, "b", 2, "c", 3)