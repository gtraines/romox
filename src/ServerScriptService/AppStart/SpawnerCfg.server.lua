local libFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("LibFinder"))

local svcFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("ServiceFinder"))

local chassisModule = require(
    game:GetService("ServerScriptService")
    :WaitForChild("Equipment")
    :WaitForChild("ChassisMain"))

local spieler = svcFinder:FindService("spieler")
local exNihilo = svcFinder:FindService("exnihilo")

local wraptor = libFinder:FindLib("Wraptor")
local linq = libFinder:FindLib("linq")

local function getSpawnerModels()
    local wsRoot = game:WaitForChild("Workspace", 5)
    -- Get Spawners

    local spawnersFolder = wsRoot:WaitForChild("Spawners")
    local vehicleSpawners = spawnersFolder:WaitForChild("VehicleSpawners")
    local spawnerModels = linq(vehicleSpawners:GetChildren()):where(function (item) return item:FindFirstChild("Touchstone") ~= nil end)

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

    local createdModelCallback = function(createdModel)
        print(createdModel.Name .. " was created with EntityId: " .. createdModel.EntityId.Value)
        chassisModule.WireUpVehicleScripts(createdModel)
        print("Vehicle scripts wired up yo")
    end

    exNihilo.CreateFromServerStorage(prototypeToSpawn, spawnLocation, createdModelCallback)

end


for spwnrMdl in getSpawnerModels() do
    print(spwnrMdl)
    spwnrMdl:FindFirstChild("Touchstone").Touched:Connect(touchedByAPlayerClosure(spwnrMdl, touchedDelegate))
end