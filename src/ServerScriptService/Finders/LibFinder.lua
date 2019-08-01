--[[
    Usage example: 
    	local libFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("Finders")
	:WaitForChild("LibFinder"))
    local rq = libFinder:FindLib("RQuery")
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedLibs = require(
    ReplicatedStorage:WaitForChild("Scripts", 5):WaitForChild("ScriptFinder", 5))
local module = replicatedLibs

return module