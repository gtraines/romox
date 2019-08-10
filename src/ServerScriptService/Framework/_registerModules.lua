local spieler = require(script.Parent:WaitForChild("Spieler"))
local lightManager = require(script.Parent:WaitForChild("LightManager"))
local exNihilo = require(script.Parent:WaitForChild("ExNihilo"))

local module = {}

module["Spieler"] = spieler
module["LightManager"] = lightManager
module["ExNihilo"] = exNihilo
module["CarAndDriver"] = require(script.Parent:WaitForChild("CarAndDriver", 2))

return module
