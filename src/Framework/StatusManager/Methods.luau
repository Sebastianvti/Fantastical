local MethodLibrary = {}

function MethodLibrary:Permanent()
	if table.find(self.CharacterSheet.Active, self.Status.Name) then 
	return {"Subtract"} end
	
	return {"Add"}
end

function MethodLibrary:Overwrite()
	if table.find(self.CharacterSheet.Active, self.Status.Name) then
		return {"Subtract", "Add"} 
	end
	
	return {"Add"}
end

return MethodLibrary
