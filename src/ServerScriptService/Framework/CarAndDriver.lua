
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print("CandD - Line 5")
local libFinder = require(ServerScriptService:WaitForChild("Finders", 5):WaitForChild("LibFinder", 2))
print("CandD - Line 7")
local exNihilo = require(script.Parent:WaitForChild("ExNihilo", 2))
print("CandD - Line 9")
local rq = libFinder:FindLib("rquery")

local elsComponents = ServerScriptService:WaitForChild("Components", 5):WaitForChild("Els", 2)
print("CandD - Line 13")
local elsHud = require(elsComponents:FindFirstChild("ElsHud"))
print("CandD - Line 15")
local module = {}

function module.__setVehicleNetworkOwnershipToPlayer(vehicleModel, occupantPlayer)
    for i, v in pairs(vehicleModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v:SetNetworkOwner(occupantPlayer)
        end
    end
end
print("CandD - Line 25")
function module.__attachGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)

    if vehicleModel ~= nil and occupantPlayer ~= nil then
        local ChassisLocal = ReplicatedStorage:WaitForChild("Scripts", 2):WaitForChild("Equipment", 2):WaitForChild("ChassisLocal"):Clone()

        if ChassisLocal:FindFirstChild("Object") == nil then
            local objInstance = Instance.new("ObjectValue")
            objInstance.Name = "Object"
            objInstance.Parent = ChassisLocal
        end

        ChassisLocal.Object.Value = vehicleModel
        ChassisLocal.Parent = occupantPlayer.PlayerGui
        ChassisLocal.Disabled = false
    end
end
print("CandD - Line 42")
function module._attachVehicleSeatHandlers(vehicleModel)
    local vehicleSeat = vehicleModel:WaitForChild("VehicleSeat")
    local seatOccupantChangedHandler = function(changedProperty)
        if changedProperty == "Occupant" and rq.GetPlayerDrivingVehicle(vehicleModel) ~= nil then
            local occupantPlayer = rq.GetPlayerDrivingVehicle(vehicleModel)
            module.__attachGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)

            module.__setVehicleNetworkOwnershipToPlayer(vehicleModel, occupantPlayer)
        end
    end
    vehicleSeat.Changed:Connect(seatOccupantChangedHandler)
end
print("CandD - Line 42")
function module._weldVehicleTogether(vehicleModel)
    local vehicleSeat = vehicleModel:WaitForChild("VehicleSeat")
    local engine = vehicleModel:WaitForChild("Engine")
    local stats = vehicleModel:WaitForChild("Stats")
    local constraints = vehicleModel:WaitForChild("Constraints")

    local Welds = Instance.new("Folder")
    Welds.Name = ("Welds")
    Welds.Parent = engine

    local SeatWeld = Instance.new("WeldConstraint")
    SeatWeld.Part0 = engine
    SeatWeld.Part1 = vehicleSeat
    SeatWeld.Parent = Welds

    for i , v in next, vehicleModel:GetDescendants() do
        if v.Name == "Holder" then
            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = engine
            WeldConstraint.Part1 = v
            WeldConstraint.Parent = Welds
        end
    end

    for i , v in next, vehicleModel.Body:GetDescendants() do
        if v:IsA("BasePart") then
            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Part0 = engine
            WeldConstraint.Part1 = v
            WeldConstraint.Parent = Welds
            v.CustomPhysicalProperties = PhysicalProperties.new(0 , 0 , 0 , 0 , 0)
        end
    end

    for i , v in next, vehicleModel:GetDescendants() do
        if v.Parent.Name == "Wheel" and v:IsA("BasePart") then
        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Part0 = v.Parent
        WeldConstraint.Part1 = v
        WeldConstraint.Parent = Welds
        v.CanCollide = false
        v.CustomPhysicalProperties = PhysicalProperties.new(0 , 0 , 0 , 0 , 0)
        end
    end
	
    for i, v in next, (vehicleModel:GetDescendants()) do
        if v:IsA("BasePart") then
        v.Anchored = false
        end
    end

end
print("CandD - Line 108")
function module._setConstraints(vehicleModel)

    RunService.Heartbeat:Connect(function()

        local stats = vehicleModel:WaitForChild("Stats")
        local constraints = vehicleModel:WaitForChild("Constraints")
        for i , v in next, constraints:GetDescendants() do
            if v:IsA("HingeConstraint") then
               v.MotorMaxTorque = stats.Torque.Value
               v.AngularSpeed = stats.TurnSpeed.Value
            end
         end
         for i , v in next, constraints:GetChildren() do
            if v:IsA("SpringConstraint") then
               v.FreeLength = stats.Height.Value
            end
         end
         for i , v in next, constraints:GetChildren() do
            if v:IsA("PrismaticConstraint") then
               v.UpperLimit = -stats.Height.Value
            end
         end
        
        if not vehicleModel.VehicleSeat.Occupant then
           for i, v in pairs(vehicleModel:GetDescendants()) do
               if v:IsA("BasePart") then
                  v:SetNetworkOwner(nil)
               end
           end
        end
    end)
end
print("CandD - Line 141")
function module.WireUpVehicleScripts(vehicleModel)
    module._weldVehicleTogether(vehicleModel)
    module._attachVehicleSeatHandlers(vehicleModel)
    module._setConstraints(vehicleModel)
    elsHud:TryExecute(vehicleModel)
end
print("CandD - Line 148")
function module.CreateVehicleFromServerStorage( prototypeId, creationLocation )
    
    local createdModelCallback = function(createdModel)
        print(createdModel.Name .. " was created with EntityId: " .. createdModel.EntityId.Value)
        module.WireUpVehicleScripts(createdModel)
        print("Vehicle scripts wired up yo")
    end

    return exNihilo.CreateFromServerStorage( "Vehicles", prototypeId, creationLocation, createdModelCallback )

end
print("CandD - Line 160")

return module
