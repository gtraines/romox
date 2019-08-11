
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


function module:ShuffleList(listToShuffle)
    self:Init()
    local shuffledList = {}
    -- The # operator may or may not actually return the correct value
    -- so we will do it sort of randomly
    local itemCount = 0
    for _, val in pairs(listToShuffle) do
        itemCount = itemCount + 1
    end
    local availableIndices = itemCount

    for i=1,itemCount do
        local selectedIndex = math.random(1, availableIndices)
		local selectedItem = table.remove(listToShuffle, selectedIndex)
        table.insert(shuffledList, selectedItem)
        availableIndices = availableIndices - 1
    end

    return shuffledList
end


return module