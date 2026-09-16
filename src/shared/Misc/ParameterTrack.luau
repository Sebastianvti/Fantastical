local ParameterTrack = {}
ParameterTrack.__index = ParameterTrack

local AverageCommand = "[Command] [Players] [Args: Enum, Text]"

function ParameterTrack.New(Parameters)
    local self = setmetatable({}, ParameterTrack)

    self.LastIndexes = 1
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
    local Result = string.gsub(Text, " +", " ")
    local SubTest = string.split(Result, " ")
    if SubTest[#SubTest] == "" then table.remove(SubTest, #SubTest) end

    print(SubTest)
    print(self.LastIndexes)
    print(#SubTest)
    if #SubTest > self.LastIndexes then print("Begin new param") end
    if #SubTest < self.LastIndexes then print("go back 1 param") end
    self.LastIndexes = #SubTest

end

return ParameterTrack