wait(0.1)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Model = script.Parent.Vehicle.Value

local VehicleSeat = Model:WaitForChild("VehicleSeat")
local Player = game.Players.LocalPlayer
local Character = workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")

local entityId = ""

local function createFolder( folderName, parentObjectInstance )
	local folderInst = Instance.new("Folder")
	folderInst.Name = folderName
	folderInst.Parent = parentObjectInstance
	return folderInst
end
-- Create topic folder
local function getOrCreateClientServerTopicCategory( categoryName )
	local eventTopicFolder = ReplicatedStorage:FindFirstChild("EventTopics")
	if eventTopicFolder == nil then
		eventTopicFolder = createFolder("EventTopics", ReplicatedStorage)
	end

	local categoryFolder = eventTopicFolder:FindFirstChild(categoryName)
	if categoryFolder == nil then
		categoryFolder = createFolder(categoryName, eventTopicFolder)
	end

	return categoryFolder
		
end

-- Create ClientServer topic in folder
local function getOrCreateClientServerTopicInCategory(categoryName, topicName)
	local categoryFolder = getOrCreateClientServerTopicCategory(categoryName)

	local topic = categoryFolder:FindFirstChild(topicName)
	if topic == nil then
		topic = Instance.new("RemoteEvent")
		topic.Name = topicName
		topic.Parent = categoryFolder
	end
	return topic
end

if Model:FindFirstChild("EntityId") then
    entityId = Model:FindFirstChild("EntityId").Value
else 
	error("Missing unique identifier EntityId on model: " .. Model.Name)
end

local function generateDelegate(entityId, button)
    local topic = getOrCreateClientServerTopicInCategory("ELS", button.Text)
    print(topic.Name)
	local activatedDelegate = function(sender)
        
        topic:FireServer(entityId)
		print("Received click from entity: " .. entityId .. " on button: " .. button.Text)
	end
	
	return activatedDelegate
end

local buttons = script.Parent:FindFirstChild("HudFrame"):GetChildren()

local function connectButton(entityId, button)
    
    if button:IsA("GuiButton") then
		button.Activated:Connect(generateDelegate(entityId, button))
		print("Added delegate handler to button: " .. button.Name)
    end
    
end

for idx, btn in pairs(buttons) do
    print("Connecting button: " .. btn.Name)
    connectButton(entityId, btn)
end

RunService.RenderStepped:Connect(function()
	if Humanoid.SeatPart ~= VehicleSeat or Humanoid.Health <= 0 then
		script.Parent.Parent = nil
		script:Destroy()
	end
end)