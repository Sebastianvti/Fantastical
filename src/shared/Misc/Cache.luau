local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local Cache = {}
Cache.__index = Cache


function Cache.New(Instance : string, Amount : number, Dynamic: boolean)
    local self = setmetatable({}, Cache)

    self.Instance = Instance
    self.Amount = Amount
    self.Dynamic = Dynamic

    self.Active = {}
    self.Reserve = self:CreateInstances()
    return self
end

function Cache:CreateInstances()
    local NewCache = {}
    for i = 1, self.Amount do 
        table.insert(NewCache, Instance.new(self.Instance))
    end
    return NewCache
end

function Cache:GetInstance()
    if #self.Reserve == 0 then
        warn("Cache containing "..(self.Instance).." was exhausted since all "..(self.Amount).." instances were used.")
        if not self.Dynamic then return end

        print("Dynamic sizing is enabled, creating new instance to compensate.")
        table.insert(self.Reserve, Instance.new(self.Instance))
    end

    table.insert(self.Active, self.Reserve[1])
    table.remove(self.Reserve, 1)
    return self.Reserve[1]
end

function Cache:Withdraw(Instance)
    table.remove(self.Active, table.find(self.Active, Instance))
    table.insert(self.Reserve, Instance)
end

return Cache