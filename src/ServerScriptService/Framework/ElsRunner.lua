

local replicatedStorage = game:GetService("ReplicatedStorage")

local libFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("LibFinder"))

local rq = libFinder:FindLib("RQuery")

local module = {}

return module