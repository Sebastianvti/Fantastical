return function(Package)
     local Main = require(script.Parent.Parent)
     Package.SubClass = "CanStack"

     local Key = (Package.Status.Name.."_Stack")
     
     if not Package.CharacterSheet.Active_Stacks[Key] then Package.CharacterSheet.Active_Stacks[Key] = {} end
     
     local MaxStackSize = Package.Status.Settings.StackSize
     local Stack = Package.CharacterSheet.Active_Stacks[Key]

     if #Stack + Main.GetTimers(Package.Status.Name, Package.Player.Character) >= MaxStackSize then return false end

     Package.Base = {"Add"}
     return true
end