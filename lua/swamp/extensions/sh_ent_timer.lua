-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- Entity timer system, timers are removed when entity is


--- A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid
function Entity:TimerSimple(delay, callback)
    timer.Simple(delay, function()
        if IsValid(self) then
            callback(self)
        end
    end)
end

--- A timer which will only call the callback (with the entity passed as the argument) if the ent is still valid
function Entity:TimerCreate(identifier, delay, repetitions, callback)
    self:TimerRemove(identifier)
    local timers = self.ENT_TIMERS
    ENTITY_TIMER_UNIQUE = (ENTITY_TIMER_UNIQUE or 0) + 1
    local timername = "ETMR-" .. tostring(ENTITY_TIMER_UNIQUE)
    timers[identifier] = timername

    timer.Create(timername, delay, repetitions, function()
        if IsValid(self) then
            callback(self)
        else
            timer.Remove(timername)
        end
    end)
end

function Entity:TimerRemove(identifier)
    self.ENT_TIMERS = self.ENT_TIMERS or {}
    local timers = self.ENT_TIMERS

    if timers[identifier] then
        timer.Remove(timers[identifier])
    end

    timers[identifier] = nil
end
