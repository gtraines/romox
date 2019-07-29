
--[[
    Randomization helpers
]]

if os == nil then
    os = require("os`")
end

if math == nil then
    math = require("math")
end

local module = {
    __seed = nil
}

function module:Init()
    self.__seed = os.time()
    math.randomseed(self.__seed)
end

function module:GetOneAtRandom( collection )
    self:Init()
    local collectionLength = #collection

    local selectedIndex = self:GetIntegerBtwn(1, collectionLength)
    return collection[selectedIndex]
end

function module:GetIntegerBtwn( start, finish )
    self:Init()
    return math.random(start, finish)
end

return module