local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local findersFolder = ServerScriptService:WaitForChild("Finders")
local libFinder = require(findersFolder:WaitForChild("LibFinder"))
local svcFinder = require(findersFolder:WaitForChild("ServiceFinder"))

local CarAndDriver = svcFinder:FindService("CarAndDriver")
local gooey = libFinder:FindLib("gooey")

local module = {}

function module.IsVehicleEmergencyVehicle(vehicleModel)
    if vehicleModel == nil
        or not vehicleModel:FindFirstChild("IsEmergencyVehicle")
        or vehicleModel:FindFirstChild("IsEmergencyVehicle").Value == false then
        return false
    end
    print(vehicleModel.Name .. " is an emergency vehicle")
    return true
end

function module.__setVehicleNetworkOwnershipToPlayer(vehicleModel, occupantPlayer)
    for i, v in pairs(vehicleModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v:SetNetworkOwner(occupantPlayer)
        end
    end
end

function module.__attachGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)

    if vehicleModel ~= nil and occupantPlayer ~= nil then
        local ChassisLocal = script.Parent.ChassisLocal:Clone()

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

function module.__attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
    local elsHud = ServerStorage:WaitForChild("UserInterfaces"):WaitForChild("ElsHud"):Clone()
    elsHud.Vehicle.Value = vehicleModel
    local elsButtons = ServerScriptService:WaitForChild("Equipment", 2):WaitForChild("ElsHudButtons"):Clone()
    elsButtons.Parent = elsHud
    elsHud.Parent = occupantPlayer.PlayerGui
    elsHud.ElsHudButtons.Disabled = false
end

function module._connectEls(vehicleModel)
    if module.IsVehicleEmergencyVehicle(vehicleModel) then
        local elsRunner = require(ServerScriptService
            :WaitForChild("Equipment", 2)
            :WaitForChild("ElsRunner"))
    
        local elsModel = vehicleModel:FindFirstChild("Body"):FindFirstChild("ELS")
        if elsModel == nil then
            error("Emergency vehicle missing member Body.ELS model")
        end
        elsRunner.ConnectEls(vehicleModel.EntityId.Value, elsModel)
    end
end

function module._attachVehicleSeatHandlers(vehicleModel)
    local vehicleSeat = vehicleModel:WaitForChild("VehicleSeat")
    local seatOccupantChangedHandler = function(changedProperty)
        if changedProperty == "Occupant" and CarAndDriver.GetPlayerDrivingVehicle(vehicleModel) ~= nil then
            local occupantPlayer = module.GetPlayerDrivingVehicle(vehicleModel)
            module.__attachGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)

            if module.IsVehicleEmergencyVehicle(vehicleModel) then
                module.__attachElsGuiToVehicleSeatOccupant(vehicleModel, occupantPlayer)
            end

            module.__setVehicleNetworkOwnershipToPlayer(vehicleModel, occupantPlayer)
        end
    end
    vehicleSeat.Changed:Connect(seatOccupantChangedHandler)
end

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

function module.WireUpVehicleScripts(vehicleModel)
    module._weldVehicleTogether(vehicleModel)
    module._attachVehicleSeatHandlers(vehicleModel)

    module._setConstraints(vehicleModel)
    module._connectEls(vehicleModel)
end


return module

