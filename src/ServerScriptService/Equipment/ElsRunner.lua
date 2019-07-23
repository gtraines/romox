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
	local wrapperFunc = function(sender, data)
		if data["entityId"] ~= nil and data.entityId == entityId then
			print(topic .. " was triggered by " .. entityId)
			print(sender.Name .. " clicked THE THING")
		end

	end
	local elsTopic = pubSub:SubscribeServerToTopicEvent("ELS", topic, listenerFunc)
end

function module.ConnectLights(entityId, elsModel)
	print("connecting lights... ")
	local getListenerfunc = function(elsModelParam)
		local lightsOn = false
		local listenerFunc = function(sender, data)
			print("Current LightsOn:" .. tostring(lightsOn))
			lightsOn = not lightsOn
			print("Post click lights: " .. tostring(lightsOn))

			local lightBar1 = elsModelParam:FindFirstChild("lightbar1")
			lightBar1.on.Value = lightsOn
		end
		return listenerFunc
	end

	--module.ConnectListenerFuncToElsTopic(entityId, "LIGHTS1", getListenerfunc())

	local elsTopic = pubSub:SubscribeServerToTopicEvent("ELS", "LIGHTS1", getListenerfunc(elsModel))
	print(elsTopic.Name .. " HAS RECEIVED A SERVER-SIDE LISTENER!@!!!!")
end

return module