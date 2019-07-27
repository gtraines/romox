local libFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("LibFinder"))

local svcFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("ServiceFinder"))

local spieler = svcFinder:FindService("spieler")
local exNihilo = svcFinder:FindService("exnihilo")

local wraptor = libFinder:FindLib("Wraptor")
local linq = libFinder:FindLib("linq")

local function getSpawnerModels()
    local wsRoot = game:WaitForChild("Workspace", 5)
    -- Get Spawners
    local spawnersFolder = wsRoot:WaitForChild("Spawners", 20)
    local spawnerModels = linq(spawnersFolder:GetChildren()):where(
        function (item)
            return item:FindFirstChild("Touchstone") ~= nil 
        end)
    return spawnerModels.list()
end

local function touchedByAPlayerClosure(spawnerModel, touchedByPlayerDelegate)

    local touchHandler = function(part)
        local playerFromPart = spieler:GetPlayerFromPart(part)
        if (playerFromPart ~= nil) then
            return touchedByPlayerDelegate(spawnerModel, playerFromPart)
        end
    end

    return wraptor.WithCoolDown(5, touchHandler)
end

local function touchedDelegate(spawnerModel, playerFromPart)
    print(
        "ALERT: " .. playerFromPart.Name .. " just touched me."
    )
    local prototypeToSpawn = spawnerModel:FindFirstChild("SpawnsPrototypeId").Value
    local touchStone = spawnerModel:FindFirstChild("SpawnPad")
    local spawnLocation = CFrame.new(touchStone.Position) + Vector3.new(0, 3, 0)
    exNihilo.CreateFromServerStorage(prototypeToSpawn, spawnLocation)

end


for spwnrMdl in getSpawnerModels() do
    print(spwnrMdl)
    spwnrMdl:FindFirstChild("Touchstone").Touched:Connect(touchedByAPlayerClosure(spwnrMdl, touchedDelegate))
end