e2function string getAggression( entity entity )
	if !ValidEntity( entity ) then return end
	
	if entity:IsPlayer() then
		local aggression = entity:GetNWString("aggression")
		return aggression
	else
		return "bad entity"
	end

end
	