wait(0.1)

local ServerScriptService = game:GetService("ServerScriptService")
local pubSubLib = require(ServerScriptService:WaitForChild("Framework", 2):WaitForChild("PubSub", 1))
local RunService = game:GetService("RunService")
local Model = script.Parent.Vehicle.Value

local VehicleSeat = Model:WaitForChild("VehicleSeat")
local Player = game.Players.LocalPlayer
local Character = workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")

local entityId = ""

if Model:FindFirstChild("EntityId") then
    entityId = Model:FindFirstChild("EntityId").Value
else 
	error("Missing unique identifier EntityId on model: " .. Model.Name)
end

local lightsTopic = pubSubLib:GetOrCreateClientServerTopicInCategory("EmergencyLightSystem", "Lights1")

local function generateDelegate(entityId, button)
	local activatedDelegate = function(sender)
		local createdEntityId = entityId
		local createdButton = button
		print("Received click from entity: " .. entityId .. " on button: " .. createdButton.Name)
	end
	
	return activatedDelegate
end

local buttons = script.Parent:FindFirstChild("HudFrame"):GetChildren()

for indexer, value in pairs(buttons) do
	if value:IsA("GuiButton") then
		value.Activated:Connect(generateDelegate(entityId, value))
		print("Added delegate handler to button: " .. value.Name)
	end
end

RunService.RenderStepped:Connect(function()
	if Humanoid.SeatPart ~= VehicleSeat or Humanoid.Health <= 0 then
		script.Parent.Parent = nil
		script:Destroy()
	end
end)