local ServerScriptService = game:GetService("ServerScriptService")
local frameworkFolder = ServerScriptService:WaitForChild("Framework", 1)

local spieler = require(frameworkFolder:WaitForChild("Spieler"))
local lightManager = require(frameworkFolder:WaitForChild("LightManager"))
local exNihilo = require(frameworkFolder:WaitForChild("ExNihilo"))

local module = {}

module["CarAndDriver"] = require(frameworkFolder:WaitForChild("CarAndDriver", 2))
module["DisplayManager"] = require(frameworkFolder:WaitForChild("DisplayManager"))
module["ExNihilo"] = exNihilo
module["LightManager"] = lightManager
module["MapManager"] = require(frameworkFolder:WaitForChild("MapManager"))
module["PlayerManager"] = require(frameworkFolder:WaitForChild("PlayerManager"))
module["Spieler"] = spieler
module["TeamManager"] = require(frameworkFolder:WaitForChild("TeamManager"))
module["TimeManager"] = require(frameworkFolder:WaitForChild("TimeManager"))

return module
