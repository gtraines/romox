local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
print("ELS - Line 4")
local libFinder = require(ServerScriptService:WaitForChild("Finders", 5):WaitForChild("LibFinder", 2))

local rq = libFinder:FindLib("rquery")
local ComponentBase = libFinder:FindLib("componentbase")
print("ELS - Line 9")
local lightsComponent = require(script.Parent:WaitForChild("Lights", 5))
print("ELS - Line 11")
local sirenComponent = require(script.Parent:WaitForChild("Sirens", 5))
print("ELS - Line 13")
local component = ComponentBase.new("ElsHud", {"elshud"})

function component._attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
    local elsHud = ServerStorage:WaitForChild("UserInterfaces"):WaitForChild("ElsHud"):Clone()
    elsHud.Vehicle.Value = vehicleModel
    local elsButtons = ReplicatedStorage:WaitForChild("Scripts", 2):WaitForChild("Equipment", 2):WaitForChild("ElsHudButtons"):Clone()
    elsButtons.Parent = elsHud
    elsHud.Parent = occupantPlayer.PlayerGui
    elsHud.ElsHudButtons.Disabled = false
end
print("ELS - Line 22")
function component._attachVehicleSeatHandlers(vehicleModel)
    local vehicleSeat = vehicleModel:WaitForChild("VehicleSeat")
    local seatOccupantChangedHandler = function(changedProperty)
        if changedProperty == "Occupant" and rq.GetPlayerDrivingVehicle(vehicleModel) ~= nil then
            local occupantPlayer = rq.GetPlayerDrivingVehicle(vehicleModel)
            component._attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
        end
    end
    vehicleSeat.Changed:Connect(seatOccupantChangedHandler)
end
print("ELS - Line 33")
function component:Execute( gameObject )
    self._attachVehicleSeatHandlers(gameObject)
    lightsComponent:TryExecute(gameObject)
    sirenComponent:TryExecute(gameObject)
 end

return component