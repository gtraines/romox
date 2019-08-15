local GameManager = {}

-- ROBLOX services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local ServerScriptService = game:GetService("ServerScriptService")
local findersFolder = ServerScriptService:WaitForChild("Finders")
local SvcFinder = require(findersFolder:WaitForChild("ServiceFinder"))
local LibFinder = require(findersFolder:WaitForChild("LibFinder", 2))

-- Game services
local Configurations = require(ServerStorage:WaitForChild("Configurations", 1))
local TeamManager = SvcFinder:FindService("TeamManager")
local PlayerManager = SvcFinder:FindService("PlayerManager")
local MapManager = SvcFinder:FindService("MapManager")
local TimeManager = SvcFinder:FindService("TimeManager")
local DisplayManager = SvcFinder:FindService("DisplayManager")

--local linq = LibFinder:FindLib("linq")
local exNihilo = SvcFinder:FindService("ExNihilo")
local randumb = LibFinder:FindLib("randumb")


local NpcAgent = require(
	ServerScriptService
		:WaitForChild("Agents", 2):WaitForChild("NpcAgent", 2))

local GameManager = {
	Waypoints = {},
	CurrentWaypointIndex = 2,
	Personage = nil
	}

-- Local Variables
local IntermissionRunning = false
local EnoughPlayers = false
local GameRunning = false
local Events = game.ReplicatedStorage.Events
local CaptureFlag = Events.CaptureFlag
local ReturnFlag = Events.ReturnFlag

-- Local Functions
function OnCaptureFlag(player)
	PlayerManager:AddPlayerScore(player, 1)
	TeamManager:AddTeamScore(player.TeamColor, 1)
	DisplayManager:DisplayNotification(player.TeamColor, 'Captured Flag!')
end

local function OnReturnFlag(flagColor)
	DisplayManager:DisplayNotification(flagColor, 'Flag Returned!')
end

-- Public Functions
function GameManager:Initialize()
	MapManager:SaveMap()
end

function GameManager:RunIntermission()
	IntermissionRunning = true
	TimeManager:StartTimer(Configurations.INTERMISSION_DURATION)
	DisplayManager:StartIntermission()
	EnoughPlayers = Players.NumPlayers >= Configurations.MIN_PLAYERS	
	DisplayManager:UpdateTimerInfo(true, not EnoughPlayers)
	spawn(function()
		repeat
			if EnoughPlayers and Players.NumPlayers < Configurations.MIN_PLAYERS then
				EnoughPlayers = false
			elseif not EnoughPlayers and Players.NumPlayers >= Configurations.MIN_PLAYERS then
				EnoughPlayers = true
			end
			DisplayManager:UpdateTimerInfo(true, not EnoughPlayers)
			wait(.5)
		until IntermissionRunning == false
	end)
	
	wait(Configurations.INTERMISSION_DURATION)
	IntermissionRunning = false
end

function GameManager:StopIntermission()
	--IntermissionRunning = false
	DisplayManager:UpdateTimerInfo(false, false)
	DisplayManager:StopIntermission()
end

function GameManager:GameReady()
	return Players.NumPlayers >= Configurations.MIN_PLAYERS
end

function GameManager:_createPath(personage, destinationObject)
	local pathParams = {
			AgentRadius = 2,
			AgentHeight = 5
	}
	
	local path = PathfindingService:CreatePath(pathParams)

	local noidRootPart = personage:FindFirstChild("HumanoidRootPart")
	-- Compute and check the path
	path:ComputeAsync(noidRootPart.Position, destinationObject.Position)
	-- Empty waypoints table after each new path computation
	self.CurrentWaypointIndex = 2
	self.Personage = personage
 	local humanoid = personage:FindFirstChild("Humanoid")
	
	if path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints and start zombie walking
		
		self.Waypoints = path:GetWaypoints()
		self["Personage"]:FindFirstChild("Humanoid"):MoveTo(
				self.Waypoints[self["CurrentWaypointIndex"]].Position)
		for _, waypunkt in pairs(self.Waypoints) do
			--print(waypunkt.Position)
		end
		humanoid.MoveToFinished:Connect(GameManager:getOnWaypointReachedDelegate())

		
	else
		-- Error (path not found); stop humanoid
		print("PATH NOT FOUND!!!")
		humanoid:MoveTo(noidRootPart.Position)
	end
end
	

function GameManager:StartRound()
	TeamManager:ClearTeamScores()
	PlayerManager:ClearPlayerScores()
	
	PlayerManager:AllowPlayerSpawn(true)
	PlayerManager:LoadPlayers()
	
	GameRunning = true
	PlayerManager:SetGameRunning(true)
	TimeManager:StartTimer(Configurations.ROUND_DURATION)

end


function GameManager:Update()
	--TODO: Add custom custom game code here

end

function GameManager:RoundOver()
	local winningTeam = TeamManager:HasTeamWon()
	if winningTeam then
		DisplayManager:DisplayVictory(winningTeam)
		return true
	end
	if TimeManager:TimerDone() then
		if TeamManager:AreTeamsTied() then
			DisplayManager:DisplayVictory('Tie')
		else
			winningTeam = TeamManager:GetWinningTeam()
			DisplayManager:DisplayVictory(winningTeam)
		end
		return true
	end
	return false
end

function GameManager:RoundCleanup()
	PlayerManager:SetGameRunning(false)
	wait(Configurations.END_GAME_WAIT)
	PlayerManager:AllowPlayerSpawn(false)
	PlayerManager:DestroyPlayers()
	DisplayManager:DisplayVictory(nil)
	TeamManager:ClearTeamScores()
	PlayerManager:ClearPlayerScores()
	TeamManager:ShuffleTeams()
	MapManager:ClearMap()
	MapManager:LoadMap()
	
end

-- Bind Events
CaptureFlag.Event:connect(OnCaptureFlag)
ReturnFlag.Event:connect(OnReturnFlag)

return GameManager
