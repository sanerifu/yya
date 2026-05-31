---@class Event
local Event = {
    events = {}
}
Event.__index = Event

---@param name string
function Event.new(name)
    if Event.events[name] then
        return Event.events[name]
    end

    ---@class Event
    local self = {
        __name = name,
        listeners = {},
    }
    Event.events[name] = self
    return setmetatable(self, Event)
end

---@param fn fun(...)
---@return fun(...) fn passed function itself
function Event:subscribe(fn)
    table.insert(self.listeners, fn)
    return fn
end

---@param fn fun(...)
function Event:unsubscribe(fn)
    for i = #self.listeners, 1, -1 do
        if fn == self.listeners[i] then
            table.remove(self.listeners, i)
            break
        end
    end
end

---@param ...any
function Event:broadcast(...)
    for i = #self.listeners, 1, -1 do
        self.listeners[i](...)
    end
end

return Event
