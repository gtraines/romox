local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")
local svcFinder = require(ServerScriptService:WaitForChild("Finders", 5):WaitForChild("ServiceFinder", 2))
local libFinder = require(ServerScriptService:WaitForChild("Finders", 5):WaitForChild("LibFinder", 2))

local CarAndDriver = svcFinder:FindService("CarAndDriver")
local gooey = libFinder:FindLib("gooey")
local ComponentBase = libFinder:FindLib("componentbase")
local lightsComponent = require(script.Parent.WaitForChild("Lights"))
local sirenComponent = require(script.Parent:WaitForChild("Sirens"))
local component = ComponentBase.new("ElsHud", "elshud")

function component:Execute( gameObject )
   self._attachVehicleSeatHandlers(gameObject)
   lightsComponent:TryExecute(gameObject)
   sirenComponent:TryExecute(gameObject)

end


function component._attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
    local elsHud = ServerStorage:WaitForChild("UserInterfaces"):WaitForChild("ElsHud"):Clone()
    elsHud.Vehicle.Value = vehicleModel
    local elsButtons = ReplicatedStorage:WaitForChild("Scripts", 2):WaitForChild("Equipment", 2):WaitForChild("ElsHudButtons"):Clone()
    elsButtons.Parent = elsHud
    elsHud.Parent = occupantPlayer.PlayerGui
    elsHud.ElsHudButtons.Disabled = false
end


function component._attachVehicleSeatHandlers(vehicleModel)
    local vehicleSeat = vehicleModel:WaitForChild("VehicleSeat")
    local seatOccupantChangedHandler = function(changedProperty)
        if changedProperty == "Occupant" and CarAndDriver.GetPlayerDrivingVehicle(vehicleModel) ~= nil then
            local occupantPlayer = CarAndDriver.GetPlayerDrivingVehicle(vehicleModel)
            component._attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
        end
    end
    vehicleSeat.Changed:Connect(seatOccupantChangedHandler)
end

return component