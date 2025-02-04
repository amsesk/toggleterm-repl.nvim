--- @class ToggleTermReplItem
--- @field id number
--- @field display_name string
--- @field type string
--- @field _length number
local ToggleTermItem = {}

function ToggleTermItem:new(id, display_name, type)
    local newitem = setmetatable({
        id = id,
        display_name = display_name,
        type = type,
    }, self)
    self.__index = self
    return newitem
end

function ToggleTermItem:display()
    return self.id .. ": " .. self.display_name 
    -- return self.id .. ", " .. self.display_name .. ", " .. self.type
end

--- @class ToggleTermList
--- @field items any[]
--- @field _length number
local ToggleTermList = {}

function ToggleTermList:new()
    local newlist = setmetatable({
        items = {},
        _length = 0,
    }, self)
    self.__index = self
    return newlist
end

function ToggleTermList:_n_entries()
    local count = 0
    for _ in pairs(self.items) do
        count = count + 1
    end
    return count
end

function ToggleTermList:display()
    local out = {}
    for i = 1, self._length do
        local v = self.items[i]
        -- out[i] = v
        out[i] = v:display()
    end

    return out
end

function ToggleTermList:append(id, display_name, type)
    table.insert(self.items, ToggleTermItem:new(id, display_name, type))
    self._length = self._length + self:_n_entries()
    return self
end

return ToggleTermList
