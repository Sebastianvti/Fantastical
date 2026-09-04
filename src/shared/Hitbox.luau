local Hitbox = {}
Hitbox.__index = Hitbox

local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

export type HitboxParams = {
    Type : string,
    Size : Vector3,
    Origin : Vector3,
    Range : number,
    Exclude : {Model},
    RayParams : RaycastParams
}

local FallbackParams = RaycastParams.new()

function Hitbox.New(Player, HitboxParams, Debug)
    local self = setmetatable({}, Hitbox)

    if not Player.Character then return end

    self.Owner = Player.Character -- FIX: POSITION NOT UPDATING FOR EACH CALL
    self.HitboxParams = HitboxParams
    self.Type = "Lone"
    self.Debug = Debug

    return self
end



function Hitbox:Play() -- Central point for hitbox plays

    self.Size =  self.HitboxParams and self.HitboxParams.Size or Vector3.new(5,3,5)
    self.Origin = self.HitboxParams and self.HitboxParams.Origin or self.Owner.HumanoidRootPart.CFrame
    self.Range = self.HitboxParams and self.HitboxParams.Range or 5
    self.RayParams = self.HitboxParams and self.HitboxParams.RayParams or FallbackParams
    self.Direction = self.Origin.LookVector * self.Range

    if self.Debug then self:Visualize() end
    self[self.Type](self)
end

function Hitbox:Continious()
    self.Cast = workspace:Blockcast(
        self.Owner.HumanoidRootPart.CFrame,
        self.Size,
        self.Owner.HumanoidRootPart.CFrame.LookVector * self.Range,
        self.RayParams
    )
    if self.Cast then
        -- if cast result is positive then continue cast but blacklist last hit, until no hits
        -- are registered
    end
end

function Hitbox:Lone()
    self.Cast = workspace:Blockcast(
        self.Owner.HumanoidRootPart.CFrame,
        self.Size,
        self.Owner.HumanoidRootPart.CFrame.LookVector * self.Range,
        self.RayParams
    )
    -- casts once and if it hits something then it will return the result and stop
end


function Hitbox:Visualize()

	local CastVisual = Instance.new("Part")
	CastVisual.Name = HttpService:GenerateGUID()
	CastVisual.Anchored = true
	CastVisual.CanCollide = false
	CastVisual.CanQuery = false
	CastVisual.CanTouch = false
	CastVisual.Transparency = 0.3
	CastVisual.Color = Color3.new(0.317647, 1, 0)
	CastVisual.Size = self.Size
	CastVisual.CFrame = self.Origin
	CastVisual.Parent = workspace
	
	local CastResult = Instance.new("Part")
	CastResult.Name = HttpService:GenerateGUID()
	CastResult.Anchored = true
	CastResult.CanCollide = false
	CastResult.CanQuery = false
	CastResult.CanTouch = false
	CastResult.Transparency = 0.3
	CastResult.Color = Color3.new(1, 0.027451, 0.0431373)
	CastResult.Size = self.Size
	CastResult.CFrame = self.Origin + self.Direction
	CastResult.Parent = workspace
	
	Debris:AddItem(CastVisual, 5)
	Debris:AddItem(CastResult, 5)
end

return Hitbox