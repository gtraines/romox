
local module = {}

local function printStJohnPolice(isStJohnPolice)
    if isStJohnPolice then
        print("It is the St John Police")
    else
        print("It is NOT the St John Police")
    end
end

module.printStJohnPolice = printStJohnPolice

return module