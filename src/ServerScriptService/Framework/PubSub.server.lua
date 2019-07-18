local svcFinder = require(game
	:GetService("ServerScriptService")
	:WaitForChild("ServiceFinder")
	:WaitForChild("Finder"))

local rq = svcFinder:FindService("RQuery")

local module = {
}

return module