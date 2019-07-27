local replicatedStorage = game:GetService("ReplicatedStorage")

local libFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("LibFinder"))

local svcFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("ServiceFinder"))

local rq = libFinder:FindLib("RQuery")
local pubSub = svcFinder:FindService("PubSub")
local module = {}

function module.GetElsModelFromVehicle(vehicleModel)
	local elsModel = vehicleModel:FindFirstChild("Body"):FindFirstChild("ELS")
	return elsModel
end

function module.ConnectListenerFuncToElsTopic(entityId, topic, listenerFunc)
	local wrapperFunc = function(sender, vehicleEntityId)
		if (vehicleEntityId ~= nil and vehicleEntityId == entityId) then
			print(topic .. " was triggered by " .. vehicleEntityId)
			listenerFunc(sender, vehicleEntityId)
		end
	end
	local elsTopic = pubSub:SubscribeServerToTopicEvent("ELS", topic, wrapperFunc)
	return elsTopic
end

function module.__getLightGroup(lightbar, groupName)
	if lightbar ~= nil and 
		lightbar:FindFirstChild(groupName)
	then
		local lightsGroupModel = lightbar:FindFirstChild(groupName)
		return lightsGroupModel:GetChildren()
	else 
		warn(lightbar.Name .. " is nil or missing " .. groupName)
	end
end

function module.__turnOnLightGroup(lightgroup)
	for _, value in pairs(lightgroup) do
		module.__turnOnLight(value)
	end
end

function module.__turnOffLightGroup(lightgroup)
	for _, value in pairs(lightgroup) do
		module.__turnOffLight(value)
	end
end


function module.__turnOnLight(lightPart)
	if lightPart:FindFirstChild("Point") ~= nil then
		lightPart.Point.Enabled = true
	end
	if lightPart:FindFirstChild("Lighto") ~= nil then
		lightPart.Lighto.Enabled = true
	end
	if lightPart.Name == "red" 
	or lightPart.Name == "white" or 
		lightPart.Name == "blue" or 
		lightPart.Name == "yellow" then
		lightPart.Material = Enum.Material.Neon
		lightPart.Transparency = 0

	end
	for idx, obj in pairs(lightPart:GetChildren()) do
		if obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or obj:IsA("PointLight") then
			obj.Enabled = true
		end
	end
end

function module.__turnOffLight(lightPart)
	if lightPart:FindFirstChild("Point") ~= nil then
		lightPart.Point.Enabled = false
	end
	if lightPart:FindFirstChild("Lighto") ~= nil then
		lightPart.Lighto.Enabled = false
	end
	if (lightPart.Name == "red" or
		lightPart.Name == "white" or 
		lightPart.Name == "blue" or 
		lightPart.Name == "yellow") and lightPart.Material == Enum.Material.Neon then
		lightPart.Material = Enum.Material.SmoothPlastic
		lightPart.Transparency = 0.6
	end
	for idx, obj in pairs(lightPart:GetChildren()) do
		if obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			obj.Enabled = false
		end
	end
end

function module.__turnOffAllLights(lightbar)
	local group1 = module.__getLightGroup(lightbar, "G1")
	local group2 = module.__getLightGroup(lightbar, "G2")
	module.__turnOffLightGroup(group1)
	module.__turnOffLightGroup(group2)
end

function module.__turnOffAllSirens(sirenPart)
	if sirenPart ~= nil and sirenPart:GetChildren() ~= nil then
		for _, siren in pairs(sirenPart:GetChildren()) do
			if siren:FindFirstChild("Stop") ~= nil then
				print("Stopping " .. siren)
				siren:Stop()
			end
		end
	end
end

function module.__stopSiren(sirenPart, sirenName)
	if sirenPart ~= nil and sirenPart:FindFirstChild(sirenName) ~= nil then
		local sirenSound = sirenPart:FindFirstChild(sirenName)
		sirenSound:Stop()
	end
end

function module.__playSiren(sirenPart, sirenName)
	
	if sirenPart ~= nil and sirenPart:FindFirstChild(sirenName) ~= nil then
		local sirenSound = sirenPart:FindFirstChild(sirenName)
		sirenSound:Play()
		sirenSound.Volume = 0.5
		sirenSound.Looped = true
	end
end
	 
function module.__executeFlashingPattern1(lightGroup1, lightGroup2)
	
	for i=1, 6 do
		module.__turnOffLightGroup(lightGroup2)
		wait(0.05)
		module.__turnOnLightGroup(lightGroup1)
		wait(0.05)
		module.__turnOffLightGroup(lightGroup1)
	end

	for i=1, 6 do
		module.__turnOffLightGroup(lightGroup1)
		wait(0.05)
		module.__turnOnLightGroup(lightGroup2)
		
		wait(0.05)
		module.__turnOffLightGroup(lightGroup2)
	end
	
end
	 
function module.__executeFlashingPattern2(lightGroup1, lightGroup2)
	wait(0.2)
	module.__turnOnLightGroup(lightGroup1)
	module.__turnOffLightGroup(lightGroup2)
	wait(0.2)
	module.__turnOffLightGroup(lightGroup1)
	module.__turnOnLightGroup(lightGroup2)
end

	 
function module.__executeFlashingPattern3(lightGroup1, lightGroup2)
	module.__turnOffLightGroup(lightGroup1)
	module.__turnOffLightGroup(lightGroup2)
	for i=1, 2 do
		wait(0.2)
		module.__turnOnLightGroup(lightGroup1)
		module.__turnOnLightGroup(lightGroup2)
		wait(0.2)
		module.__turnOffLightGroup(lightGroup1)
		module.__turnOffLightGroup(lightGroup2)
	end
end

function module._getLights1ListenerFunc(elsModel)
	
	local lightbar1 = elsModel:FindFirstChild("lightbar1")
	if lightbar1:FindFirstChild("on") == nil then
		local onValue = Instance.new("BoolValue")
		onValue.Value = false
		onValue.Name = "on"
		onValue.Parent = lightbar1
	end
	module.__turnOffAllLights(lightbar1)
	lightbar1.on.Value = false
	local lightsOn = false
	local listenerFunc = function(sender, data)
		print("Current LightsOn:" .. tostring(lightsOn))
		lightsOn = not lightsOn

		lightbar1.on.Value = lightsOn
		local lightGroup1 = module.__getLightGroup(lightbar1, "G1")
		local lightGroup2 = module.__getLightGroup(lightbar1, "G2")

		if lightbar1.on.Value then
			while lightbar1.on.Value do
				for iter = 1, 2 do
					if (lightbar1.on.Value) then
						module.__executeFlashingPattern1(lightGroup1, lightGroup2)
					end
				end
				for iter = 1, 4 do
					if (lightbar1.on.Value) then
						module.__executeFlashingPattern2(lightGroup1, lightGroup2)
					end
				end
				for iter = 1, 2 do
					if (lightbar1.on.Value) then
						module.__executeFlashingPattern3(lightGroup1, lightGroup2)
					end
				end
			end
		end
		module.__turnOffAllLights(lightbar1)
	end

	return listenerFunc

end

function module._getLights2ListenerFunc(elsModel)
	
	local lightbar2 = elsModel:FindFirstChild("lightbar2")
	if lightbar2:FindFirstChild("on") == nil then
		local onValue = Instance.new("BoolValue")
		onValue.Value = false
		onValue.Name = "on"
		onValue.Parent = lightbar2
	end
	module.__turnOffAllLights(lightbar2)
	lightbar2.on.Value = false
	local lightsOn = false
	local listenerFunc = function(sender, data)
		print("Current LightsOn:" .. tostring(lightsOn))
		lightsOn = not lightsOn

		lightbar2.on.Value = lightsOn
		local lightGroup1 = module.__getLightGroup(lightbar2, "G1")
		local lightGroup2 = module.__getLightGroup(lightbar2, "G2")

		if lightbar2.on.Value then
			while lightbar2.on.Value do
				module.__turnOnLightGroup(lightGroup1)
				wait(0.5)
			end
		else
			module.__turnOffAllLights(lightbar2)
		end
	end

	return listenerFunc

end

function module._getSiren1ListenerFunc(elsModel)
	
	local sirenPart = elsModel:FindFirstChild("Siren")
	local sirenSound = sirenPart:FindFirstChild("Wail")
	sirenSound.EmitterSize = 10
	local siren1On = false

	local listenerFunc = function(sender, data)
		module.__turnOffAllSirens(sirenPart)

		siren1On = not siren1On

		if siren1On == true then
			module.__playSiren(sirenPart, "Wail")
		else 
			module.__stopSiren(sirenPart, "Wail")
		end
	end
	return listenerFunc
end

function module._getSiren2ListenerFunc(elsModel)
	
	local sirenPart = elsModel:FindFirstChild("Siren")
	local sirenSound = sirenPart:FindFirstChild("Yelp")
	sirenSound.EmitterSize = 10
	local siren2On = false
	local listenerFunc = function(sender, data)
		module.__turnOffAllSirens(sirenPart)

		siren2On = not siren2On

		if siren2On == true then
			module.__playSiren(sirenPart, "Yelp")
		else 
			module.__stopSiren(sirenPart, "Yelp")
		end
	end
	return listenerFunc
end

function module.ConnectLights(entityId, elsModel)
	print("connecting lights... ")

	local elsTopicLights1 = module.ConnectListenerFuncToElsTopic(entityId, "LIGHTS1", module._getLights1ListenerFunc(elsModel))
	print(elsTopicLights1.Name .. " HAS RECEIVED A SERVER-SIDE LISTENER!@!!!!")
	

	local elsTopicLights2 = module.ConnectListenerFuncToElsTopic(entityId, "LIGHTS2", module._getLights2ListenerFunc(elsModel))
	print(elsTopicLights2.Name .. " HAS RECEIVED A SERVER-SIDE LISTENER!@!!!!")

	return true
end

function module.ConnectSirens(entityId, elsModel)
	print("connecting sirens... ")

	local elsTopicSiren1 = module.ConnectListenerFuncToElsTopic(entityId, "SIREN1", module._getSiren1ListenerFunc(elsModel))
	print(elsTopicSiren1.Name .. " HAS RECEIVED A SERVER-SIDE LISTENER!@!!!!")
	
	local elsTopicSiren2 = module.ConnectListenerFuncToElsTopic(entityId, "SIREN2", module._getSiren2ListenerFunc(elsModel))
	print(elsTopicSiren2.Name .. " HAS RECEIVED A SERVER-SIDE LISTENER!@!!!!")

	return true
end

function module.ConnectEls(entityId, elsModel)

	local connectLightsSuccess = module.ConnectLights(entityId, elsModel)
	local connectSirensSuccess = module.ConnectSirens(entityId, elsModel)

	return connectLightsSuccess and connectSirensSuccess
end
return module