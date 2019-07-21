local replicatedStorage = game:GetService("ReplicatedStorage")

local libFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("LibFinder"))

local rq = libFinder:FindLib("RQuery")

local module = {
	__replicatedStorage = replicatedStorage
}

-- Create ClientServer topic

-- Create ClientServer topic with callback
-- For every RemoteFunction, only one callback can be defined on the server and only one for each client.
-- Aka remote function?

-- Create topic folder
function module:GetOrCreateClientServerTopicCategory( categoryName )
	if self.__replicatedStorage:WaitForChild(categoryName, 1) ~= nil then
		return self.__replicatedStorage.First
	end
end

-- Create ClientServer topic in folder

-- Subscribe Server to event topic

-- Subscribe Client to ClientServer event topic

-- Create Server side event topic


return module