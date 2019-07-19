--- Sugar for creating items out of thin air
-- @module ExNihilo

-- @export table actually exported by the module for use

local libFinder = require(game:GetService("ServerScriptService")
    :WaitForChild("Finders", 5)
    :WaitForChild("LibFinder", 5))

local linq = libFinder:FindLib("linq")
local serverStorage =  game:GetService("ServerStorage")

local module = {}


-- ExampleSetterFunction = exNihilo.MoveModelToCoordFrame(workspace:WaitForChild("Model"), CFrame.new(0,5,0))
function module.MoveModelToCoordFrame( modelWithPrimaryPart, newCoordFrame )
    
    local Primary = modelWithPrimaryPart.PrimaryPart or error(modelWithPrimaryPart.Name .. " has no PrimaryPart")
    local PrimaryCF = Primary.CFrame
    local Cache = {}
    
    for _, Desc in next, modelWithPrimaryPart:GetDescendants() do
        if Desc ~= Primary and Desc:IsA("BasePart") then
            Cache[Desc] = PrimaryCF:toObjectSpace(Desc.CFrame)
        end
    end
    
    Primary.CFrame = newCoordFrame
    for Part, Offset in next, Cache do
        Part.CFrame = newCoordFrame * Offset
    end
end

function module.CreateFromServerStorage( itemIdentifier, coordsForNewInstance )
    local foundItem = linq(serverStorage:GetChildren()):single(function( itm )
        return itm.Name == itemIdentifier
    end)
    
    module.MoveModelToCoordFrame(foundItem, coordsForNewInstance)
end

return module