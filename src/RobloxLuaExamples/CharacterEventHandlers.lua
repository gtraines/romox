
--[[
    Accessory Remover
This code sample automatically removes Accessory objects like hats from the Player's character when they respawn. 
Warning: this includes hair, so this script may cause acute baldness.

When the Character is added, we wait for RunService.Stepped to fire once (using the wait function of events). 
    This is so the accessory removal logic runs one frame after the character spawns. 
    A warning can appear if you delete accessories too quickly after the player spawns, so waiting one frame will avoid that.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
 
-- Check if the given object is an Accessory (such as a hat)
local function destroyAccessories(object)
	if object:IsA("Hat") or object:IsA("Accessory") then
		object:Destroy()
	end
end
 
local function onCharacterAdded(character)
	-- Wait a brief moment before removing accessories to avoid the
	-- "Something unexpectedly set ___ parent to NULL" warning
	RunService.Stepped:wait()
	-- Check for any existing accessories in the player's character
	for _, child in pairs(character:GetChildren()) do
		destroyAccessories(child)
	end
	-- Hats may be added to the character a moment after
	-- CharacterAdded fires, so we listen for those using ChildAdded
	character.ChildAdded:Connect(destroyAccessories)
end
 
local function onPlayerAdded(player)
	-- Listen for spawns
	player.CharacterAdded:Connect(onCharacterAdded)
end
 
Players.PlayerAdded:Connect(onPlayerAdded)

--[[
    Respawn at Despawn Location
This code sample will cause players to respawn at the same place they died. 
It does this by keeping track of where the player despawned using Player.CharacterRemoving. 
Note that the player’s location is saved on-despawn, not on-death. 
This can be problematic if the player falls off a ledge and dies due to Workspace.FallenPartsDestroyHeight - their respawn position won’t be saved in this case.

It’s also important to note the need to “forget” the location of players who leave the game. 
We use Instance.ChildRemoved on Players instead of Players.PlayerRemoving. 
This is because PlayerRemoving fires before CharacterRemoving 
- and we need to make sure we don’t forget the player’s respawn location then immediately remember a new one 
    (this is a memory leak; potentially many players could visit, respawn and leave). 
    So, we use ChildRemoved on Players so the event fires after the character is removed.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
 
-- This table maps "Player" objects to Vector3
local respawnLocations = {}
 
local function onCharacterAdded(character)
	local player = Players:GetPlayerFromCharacter(character)
	-- Check if we saved a respawn location for this player
	if respawnLocations[player] then
		-- Teleport the player there when their HumanoidRootPart is available
		local hrp = character:WaitForChild("HumanoidRootPart")
		-- Wait a brief moment before teleporting, as Roblox will teleport the
		-- player to their designated SpawnLocation (which we will override)
		RunService.Stepped:wait()
		hrp.CFrame = CFrame.new(respawnLocations[player] + Vector3.new(0, 3.5, 0))
	end
end
 
local function onCharacterRemoving(character)
	-- Get the player and their HumanoidRootPart and save their death location
	local player = Players:GetPlayerFromCharacter(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		respawnLocations[player] = hrp.Position
	end
end
 
local function onPlayerAdded(player)
	-- Listen for spawns/despawns
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)
end
 
local function onPlayerRemoved(player)
	-- Forget the respawn location of any player who is leaving; this prevents
	-- a memory leak if potentially many players visit
	respawnLocations[player] = nil
end
 
-- Note that we're NOT using PlayerRemoving here, since CharacterRemoving fires
-- AFTER PlayerRemoving, we don't want to forget the respawn location then instantly
-- save another right after 
Players.PlayerAdded:Connect(onPlayerAdded)
Players.ChildRemoved:Connect(onPlayerRemoved)


--[[
    Detecting Player Spawns and Despawns
This code sample demonstrates the usage of 
  Players.PlayerAdded, 
  Player.CharacterAdded and 
  Player.CharacterRemoving in order to detect the spawning and despawning of players’ characters. 
You can use this as a boilerplate script to make changes to players’ characters as they spawn, such as changing Humanoid.WalkSpeed.
]]

local Players = game:GetService("Players")
 
local function onCharacterAdded(character)
	print(character.Name .. " has spawned")
end
 
local function onCharacterRemoving(character)
	print(character.Name .. " is despawning")
end
 
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)
end
 
Players.PlayerAdded:Connect(onPlayerAdded)