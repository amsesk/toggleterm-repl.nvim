--- @class ToggleTermReplItem
--- @field id number
--- @field display_name string
--- @field type string
--- @field _length number
local ToggleTermReplItem = {}

function ToggleTermReplItem:new(id, display_name, type)
    newitem = setmetatable({
        id = id,
        display_name = display_name,
        type = type,
    }, self)
    self.__index = self
    return newitem
end

function ToggleTermReplItem:display()
    return self.id .. ", " .. self.display_name .. ", " .. self.type
end

--- @class ToggleTermReplList
--- @field items any[]
--- @field _length number
local ToggleTermReplList = {}

function ToggleTermReplList:new()
    newlist = setmetatable({
        items = {},
    }, self)
    self.__index = self
    return newlist
end

function ToggleTermReplList:display()
    local out = {}
    for i = 1, self._length do
        local v = self.items[i]
        print(vim.inspect(v.id))
        out[i] = v == nil and "" or v:display()
    end

    return out
end

function ToggleTermReplList:append(id, display_name, type)
    table.insert(self.items, ToggleTermReplItem:new(id, display_name, type))
    return self
end

return ToggleTermReplList
