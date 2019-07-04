
local lemur = require("lemur")
local habitat = lemur.Habitat.new()

local ServerScriptService = habitat.game:GetService("ServerScriptService")
game = habitat.game

local finder = habitat:loadFromFs("../ServerScriptService/ServiceFinder")
finder.Parent = ServerScriptService

local sharedLibs = habitat:loadFromFs("../ServerScriptService/SharedLibs")
sharedLibs.Parent = ServerScriptService

local dataAccess = habitat:loadFromFs("../ServerScriptService/DataAccess")
dataAccess.Parent = ServerScriptService

local appStart = habitat:loadFromFs("../ServerScriptService/AppStart")
appStart.Parent = ServerScriptService

local gameControllers = habitat:loadFromFs("../ServerScriptService/GameControllers")
gameControllers.Parent = ServerScriptService

-- load ServiceFinder within habitat?
local svcFinder = habitat:require(finder.Finder)


local rq = svcFinder:FindService("RQuery")

assert(rq ~= nil)