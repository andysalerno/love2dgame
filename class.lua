class = {}

function class:new(...)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if o.init then o:init(...) end
    return o
end

-- same as new(), but first arg is an initializing table
function class:newT(o, ...)
    assert(o ~= nil)
    local o = o
    setmetatable(o, self)
    self.__index = self
    if o.init then o:init(...) end
    return o
end
