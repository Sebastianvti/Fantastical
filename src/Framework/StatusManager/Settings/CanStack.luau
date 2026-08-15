return function(Package)
     Package.SubClass = "CanStack"

     local Key = (Package.Status.Name.."_Stack")
     
     if not Package.CharacterSheet.Active_Stacks[Key] then Package.CharacterSheet.Active_Stacks[Key] = {} end
     
     local MaxStackSize = Package.Status.Settings.StackSize
     local Stack = Package.CharacterSheet.Active_Stacks[Key]

     for Index,_ in Stack do
          if Index >= MaxStackSize then return false end
     end

     Package.Base = {"Add"}
     return true
end