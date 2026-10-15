return function(Package)
     local Main, Key = require(script.Parent.Parent), (Package.Name.."_Stack")
     
     if not Package.CharacterSheet.Active_Stacks[Key] then Package.CharacterSheet.Active_Stacks[Key] = {} end
     
     local Stack, MaxStackSize = Package.CharacterSheet.Active_Stacks[Key], Package.Status.Settings.StackSize

     if #Stack + Main.GetTimers(Package.Name, Package.Player.Character) >= MaxStackSize then return {Result = false, ErrorMsg = "Stack reached max size."} end

     Package.SubClass = "CanStack"
     Package.Base = {"Add"}
     
     return {Result = true}
end