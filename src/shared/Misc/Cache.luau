local HttpService = game:GetService("HttpService")

local Cache = {}
Cache.__index = Cache

-- in order to improve performance, on run time scripts call the cache in order to store instances that will be used later.
-- supports both instance.new and currently existing instances.

function Cache.New(Instance : Instance | string, Amount : number, ExpansionType: "Double" | "Increment"?, IncrementSize : number?)
    local self = setmetatable({}, Cache)

    self.Identification =  string.sub(HttpService:GenerateGUID(false),1, 7)
    self.Instance = Instance
    self.Amount = math.round(Amount)
    self.ExpansionType = ExpansionType
    -- Types
    -- Double will simply double the amount that existed from start, so 150 is 300 now
    -- Increment will increase by the number specieifed, so 150 is 160. pretty simple

    if not IncrementSize or IncrementSize < 1 then IncrementSize = 1 end
    self.IncrementSize = math.round(IncrementSize) or 1

    self.Reserve = self:CreateInstances()
    return self
end

function Cache:CreateInstances(Reserve : {Instance}, Amount : number)
    local NewCache, Amount = Reserve or {}, Amount or self.Amount

    if typeof(self.Instance) == "string" then
        for _ = 1, Amount do table.insert(NewCache, Instance.new(self.Instance)) end
    else
        for _ = 1, Amount do table.insert(NewCache, self.Instance:Clone()) end
    end
    return NewCache
end

function Cache:GetInstance()
    if #self.Reserve == 0 then
        warn("Cache containing "..(self.Instance).." was exhausted since all "..(self.Amount).." instances were used.")
        if not self.ExpansionType then return end

        print("Dynamic sizing is enabled, creating new instance to compensate.")
        self:CreateInstances(self.Reserve, Cache[self.ExpansionType](self))
    end

    local Asset = self.Reserve[1] table.remove(self.Reserve, 1)
    return Asset
end

function Cache:Withdraw(Instance)
    table.insert(self.Reserve, Instance)
end

function Cache.Increment(self)
    return math.round(self.IncrementSize)
end

function Cache.Double(self)
    return math.round(self.Amount)
end

return Cache