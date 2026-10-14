local Assign = {} -- This script assigns properties as attributes so they are easier to access when turning invisible on holsters. This is to avoid a big if else chain, i will just make it happen once on runtime

function Assign.Classes(Tool : Tool | Model)
    for _,Value in Tool:GetDescendants() do
        if Value:IsA("BasePart") then
            Value:SetAttribute("Property", "Transparency")
            Value:SetAttribute("Value", Value.Transparency)
        -- elseif Value:IsA("ParticleEmitter") then -- i suppose youll just have to ask why this is all commented out
        --     Value:SetAttribute("Property", "Enabled")
        --     Value:SetAttribute("Value", Value.Enabled)
        -- elseif Value:IsA("Light") then
        --     Value:SetAttribute("Property", "Enabled")
        --     Value:SetAttribute("Value", Value.Enabled)
        end
    end
end

return Assign