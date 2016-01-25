class = {}

function class:new(...)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    if o.init then o:init(...) end
    return o
end
