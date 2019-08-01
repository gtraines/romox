local libFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders", 5)
    :WaitForChild("LibFinder", 2))
print("Loaded Libfinder")
local svcFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders", 5)
    :WaitForChild("ServiceFinder", 2))
print("Loaded Service finder")
local spieler = svcFinder:FindService("spieler")
local carAndDriver = svcFinder:FindService("CarAndDriver")

local wraptor = libFinder:FindLib("Wraptor")
local linq = libFinder:FindLib("linq")
local rq = libFinder:FindLib("rquery")
print("Loaded libraries")
local function getSpawnerModels(categoryName)
    local wsRoot = game:WaitForChild("Workspace", 5)
    -- Get Spawners

    local spawnersFolder = wsRoot:WaitForChild("Spawners")
    local vehicleSpawners = spawnersFolder:WaitForChild(categoryName)
    local spawnerModels = linq(vehicleSpawners:GetChildren()):where(
        function (item) return item:FindFirstChild("Touchstone") ~= nil end)

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
    local prototypeToSpawn = rq.StringValueOrNil("SpawnsPrototypeId", spawnerModel)
    local touchStone = spawnerModel:FindFirstChild("SpawnPad")
    local spawnLocation = CFrame.new(touchStone.Position) + Vector3.new(0, 3, 0)
    return carAndDriver.CreateVehicleFromServerStorage(prototypeToSpawn, spawnLocation)
end

for spwnrMdl in getSpawnerModels("VehicleSpawners") do
    print(spwnrMdl)
    spwnrMdl:FindFirstChild("Touchstone").Touched:Connect(touchedByAPlayerClosure(spwnrMdl, touchedDelegate))
end