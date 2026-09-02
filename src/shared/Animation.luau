local Animation = {}
Animation.__index = Animation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Cache = require(Shared.Cache)

local Priority = {}

function Animation.LoadPackage(self, Package)

end

function Animation:Stopped()
    print("?")
    self.AnimationInstance.Deployed = false
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
    
    self.Track.Stopped:Connect(function() self:Stopped() end)
    self.Connections = {}

    if PlayNow then self:Play() return end
    return self
end

function Animation:Play()
    self.Track:Play()
end

function Animation:Event(Event, Function)
	self.Connections[Event] = self.Track:GetMarkerReachedSignal(Event):Connect(Function)
end

return Animation