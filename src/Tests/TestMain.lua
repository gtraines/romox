
local lemur = require("lemur")
local habitat = lemur.Habitat.new()

local ServerScriptService = habitat.game:GetService("ServerScriptService")
local game = habitat.game

local sharedLibs = habitat:loadFromFs("../ServerScriptService/SharedLibs")
sharedLibs.Parent = ServerScriptService

local finderFolder = habitat:loadFromFs("../ServerScriptService/Finders")
finderFolder.Parent = ServerScriptService

local frameworkFolder = habitat:loadFromFs("../ServerScriptService/Framework")
frameworkFolder.Parent = ServerScriptService

local gameModules = habitat:loadFromFs("../ServerScriptService/GameModules")
gameModules.Parent = ServerScriptService

local appStart = habitat:loadFromFs("../ServerScriptService/AppStart")
appStart.Parent = ServerScriptService

local module = {
    game = game,
    habitat = habitat,
    ServerScriptService = ServerScriptService
}

return module