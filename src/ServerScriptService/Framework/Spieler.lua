-- a place to group general player sugar functions
-- @module spieler

local libFinder = require(game:GetService("ServerScriptService")
    :FindFirstChild("Finders")
    :FindFirstChild("LibFinder"))

local rq = libFinder:FindLib("rquery")

local playerSvc = game:GetService("Players")

-- @export spieler the module that actually gets exported
local spieler = {
    __playersSvc = playerSvc
}

--- AddOnJoinedHandler adds a handler to the list of funcs fired on a successful join by a player
-- @param handlerFunc a function which receives the player as an arg when the event fires
function spieler:AddOnJoinedHandler(handlerFunc)
    self.__playersSvc.PlayerAdded:Connect(handlerFunc)
    return
end


--- AddOnDisconnectingHandler adds a handler to the list of funcs fired when the player begins to disconnect
-- @param [function] handlerFunc a function which receives the [Instance] player as an arg when the event fires
function spieler:AddOnDisconnectingHandler(handlerFunc)
    self.__playersSvc.PlayerDisconnecting:Connect(handlerFunc)
end

-- @param [function] handlerFunc a function which receives the player as an arg when the event fires
function spieler:AddOnLeavingGameHandler(handlerFunc)
    self.__playersSvc.PlayerRemoving:Connect(handlerFunc)
end

-- @param [function] handlerFunc a function which receives the CHARACTER as an arg when the event fires
function spieler:AddOnSpawningHandler(handlerFunc)
    self.__playersSvc.CharacterAdded:Connect(handlerFunc)
end

-- @param [function] handlerFunc a function which receives the CHARACTER as an arg when the event fires
function spieler:AddOnPlayerDiedHandler(handlerFunc)
    self.__playersSvc.CharacterRemoving:Connect(handlerFunc)
end

function spieler:GetPlayerFromPart( part )
    local character = rq:AttachedCharacterOrNil(part)
    if character ~= nil then
        return self.__playersSvc:GetPlayerFromCharacter(character)
    end
    return nil
end

return spieler