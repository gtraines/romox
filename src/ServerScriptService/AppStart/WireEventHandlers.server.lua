

local libFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("LibFinder"))

local svcFinder = require(game
    :GetService("ServerScriptService")
    :WaitForChild("Finders")
    :WaitForChild("ServiceFinder"))

local spieler = svcFinder:FindService("spieler")
local rq = libFinder:FindLib("RQuery")
local wraptor = libFinder:FindLib("Wraptor")
local linq = libFinder:FindLib("linq")

local function getSpawnerModels()
    local wsRoot = game:WaitForChild("Workspace", 5)
    -- Get Spawners
    local spawnersFolder = wsRoot:WaitForChild("Spawners", 20)
    local spawnerModels = linq(spawnersFolder:GetChildren()):where(function (item) return item:FindFirstChild("Touchstone") ~= nil end)
    return spawnerModels.list()
end

local function touchedByAHumanoidClosure(spawnerModel, onTouchedByHumanoidDelegate)

    local touchStone = spawnerModel:FindFirstChild("Touchstone")
    
    local touchHandler = function(part)
        if rq.AttachedHumanoidOrNil(part) ~= nil then
            return onTouchedByHumanoidDelegate(part)
        end
    end

    return wraptor.WithCoolDown(1, touchHandler)
end

local function touchedDelegate(part)
    print(
        "ALERT: " .. rq.AttachedHumanoidOrNil(part).Name .. " just touched me."
    )
    -- get player
end


for spwnrMdl in getSpawnerModels() do
    print(spwnrMdl)
    spwnrMdl:FindFirstChild("Touchstone").Touched:Connect(touchedByAHumanoidClosure(spwnrMdl, touchedDelegate))
end