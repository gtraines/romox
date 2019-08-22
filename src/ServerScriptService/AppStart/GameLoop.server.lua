local ServerScriptService = game:GetService("ServerScriptService")

local gameModulesFolder = ServerScriptService:WaitForChild("GameModules")
local GameManager = require(gameModulesFolder:WaitForChild("GameManager", 1))

local appStartFolder = ServerScriptService:WaitForChild("AppStart", 1)
local Spawners = require(appStartFolder:WaitForChild("Spawners", 1))
local npcAgent = require(ServerScriptService:WaitForChild("Agents"):WaitForChild("NpcAgent"))

--- Main injection point for the game
-- @script ServerMain

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

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
        npcAgent.CreateFarmerCurtis()
        
        repeat
            GameManager:Update()
            wait(0.1)
        until GameManager:RoundOver()
        
        GameManager:RoundCleanup()
    end
end

OneTimeSetup()
RunForever()