local ServerScriptService = game:GetService("ServerScriptService")

local gameModulesFolder = ServerScriptService:WaitForChild("GameModules")
local GameManager = require(gameModulesFolder:WaitForChild("GameManager", 1))

local appStartFolder = ServerScriptService:WaitForChild("AppStart", 1)
local Spawners = require(appStartFolder:WaitForChild("Spawners", 1))

function OneTimeSetup()
    Spawners.Init()
    GameManager:Initialize()
end

function RunForever()
    while true do
        repeat
            GameManager:RunIntermission()
        until GameManager:GameReady()
        
        GameManager:StopIntermission()
        GameManager:StartRound()	
        
        repeat
            GameManager:Update()
            wait(0.1)
        until GameManager:RoundOver()
        
        GameManager:RoundCleanup()
    end
end

OneTimeSetup()
RunForever()
