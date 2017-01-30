e2function number entity:changeCap( number amount )
	if !ValidEntity( this ) then return end
		
	local reqaccess = GetConVar( "access_changecap" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
		if this.SC_CoreEnt != nil then
			local core = this.SC_CoreEnt
			if amount > 0 then
				core:GenerateCap( amount )
			elseif amount < 0 then
				pamount = math.abs( amount )
				core:ConsumeCap( pamount )
			end
			return 1
		else
			return 0
		end
	end
	
end
	