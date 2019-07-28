local PlayersService = game:GetService("Players")
local exNihilo = require(game:GetService("ServerScriptService"):WaitForChild("Framework"):WaitForChild("ExNihilo")

local module = {}

function module.GetPlayerDrivingVehicle(vehicleModel)
    if vehicleModel ~= nil and
         vehicleModel:FindFirstChild("VehicleSeat") ~= nil and 
         vehicleModel:FindFirstChild("VehicleSeat").Occupant ~= nil then
            local occupantCharacter = vehicleModel:FindFirstChild("VehicleSeat").Occupant.Parent
            local occupantPlayer = PlayersService:GetPlayerFromCharacter(occupantCharacter)
            return occupantPlayer
         end

    return nil
end

function module.CreateVehicleFromServerStorage( prototypeId, creationLocation )
    
    local createdModelCallback = function(createdModel)
        print(createdModel.Name .. " was created with EntityId: " .. createdModel.EntityId.Value)
        chassisModule.WireUpVehicleScripts(createdModel)
        print("Vehicle scripts wired up yo")
    end

    return exNihilo.CreateFromServerStorage(prototypeToSpawn, spawnLocation, createdModelCallback)

end

return module
