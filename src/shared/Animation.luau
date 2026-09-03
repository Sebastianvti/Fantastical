local Animation = {}
Animation.__index = Animation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Cache = require(Shared.Cache)

function Animation.LoadPackage(self, Package)

end

function Animation:Stopped()
    print("?")
   	if self.AnimationInstance then self.AnimationInstance.Deployed = false end
        for _, connection in pairs(self.Connections or {}) do
		connection:Disconnect()
	end
	self.Connections = {}
end

function Animation.New(Player : Player, AnimationId : number, PlayNow : boolean?)
    local self = setmetatable({}, Animation)
    if not Player.Character then return end

    self.Player = Player
    self.Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

    self.AnimationInstance = Cache.GetAnimation()
    self.Animator = self.Humanoid.Animator
    self.AnimationName = self.AnimationInstance.ID
    self.Animation = self.AnimationInstance.Animation
    self.Animation.AnimationId = ('rbxassetid://'..AnimationId)

    self.Track = self.Animator:LoadAnimation(self.Animation)
    self.Track.Looped = false
    
    self.Track.Stopped:Once(function() self:Stopped() end)
    self.Connections = {}
 
    return self
end

function Animation:Play()
    self.Track:Play()
end

function Animation:Event(Event, Function)
	self.Connections[Event] = self.Track:GetMarkerReachedSignal(Event):Once(Function)
end

return Animation