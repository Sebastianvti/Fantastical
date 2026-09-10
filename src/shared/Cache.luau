local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Cache = {}
Cache.__index = Cache

Stash = {
    Sounds = {},
    Animations = {}
}

local PreloadServices = {
    Animation = 4,
    --Sound = 10
}

local function GenName(Prefix : string)
    return (Prefix.."_"..string.sub(HttpService:GenerateGUID(false), 1, 7))
end

function Cache:AddToCache(Storage : string)
    Stash[Storage][self.ID] = {}
    Stash[Storage][self.ID] = self
end

function Cache.NewAnimation(Deploy : boolean?)
    local self = setmetatable({}, Cache)

    self.ID = GenName("Animations")
    self.Animation = Instance.new("Animation")
    self.Deployed = Deploy or false -- Default is false, but if you are using it immeediately best set it to true

    self:AddToCache("Animations")
    return self
end

function Cache.NewSound(Deploy : boolean?)
    local self = setmetatable({}, Cache)

    self.ID = GenName("Sounds")
    self.Attachment = Instance.new("Attachment")
    self.Sound = Instance.new("Sound")
    self.Deployed = Deploy or false

    self:AddToCache("Sounds")
    return self
end

function Cache.GetAnimation()
    for _,Value in Stash.Animations do
        if not Value.Deployed then return Value end
    end
    warn("Cache is full, creating new instance")
    return Cache.NewAnimation()
end

function Cache.Start()
    if not RunService:IsClient() then return end
    
    for Key,Instances in PreloadServices do
        for i = 1, Instances do
            Cache["New"..Key]()
        end
    end
    print("[Preloaded Cache]: ", Stash.Animations)
end

return Cache