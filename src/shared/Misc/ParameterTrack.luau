local ParameterTrack = {}
ParameterTrack.__index = ParameterTrack

local AverageCommand = "[Command] [Players] [Args: Enum, Text]"

function ParameterTrack.New(Parameters)
    local self = setmetatable({}, ParameterTrack)

    self.Parameters = Parameters
    self:Deconstruct()
    return self
end

function ParameterTrack:Deconstruct()
    local NewList = {}

    for _,Parameter in self.Parameters do
        local Param = string.split(Parameter, ":")[1]

        Param = string.gsub(Param, "%s+", "") -- Just incase i mispell and add a space that shouldnt be there
        table.insert(NewList, Param)
    end
    self.Parameters = NewList
end

function ParameterTrack:Track(Text)
    local fakeparams = {""}
    local Result = string.gsub(Text, " +", " ")
    local SubTest = string.split(Text, " ")
    print(string.len(SubTest[#SubTest]))
    if string.len(SubTest[#SubTest]) == 1 then print("Begin new param") end

    print(Result)
end

return ParameterTrack