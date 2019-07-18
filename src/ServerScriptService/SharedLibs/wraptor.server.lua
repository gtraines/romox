
local module = {}

function module.WithCoolDown( coolDownTime, func )
    -- body
    local generatedClosure = function(innerCoolDownTime, wrappedFunction)
        local innerCoolDown = innerCoolDownTime
        local canExecute = true

        local innerExecutableFunc = function(...)
            if canExecute then
                wrappedFunction(...)
                canExecute = false
                wait(innerCoolDown)
                canExecute = true
            end

        end

        return innerExecutableFunc

    end

    return generatedClosure(coolDownTime, func)
end

return module