e2function void entity:antiPhase( number radius, vector pos )
	if !ValidEntity( this ) then return end
	
	local core = nil
	local e2 = self.entity
	
	local reqaccess = GetConVar( "access_anti_phase" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	if plyaccess >= reqaccess then
		local targets = ents.FindInSphere( pos, radius )
		
		for k, v in pairs( targets ) do
			if( ValidEntity( v ) ) then
				local class = v:GetClass()
				if !v:IsWorld() then
					if class == "prop_physics" or class == "gmod_wire_*" or class == "ship_core_*" or class == "prop_vehicle_prisoner_pod" then
						if class != "gmod_wire_hologram" and class != "ship_core_base" then
							v:SetNotSolid( false )
						end
					end
				end
			end
		end
	elseif ValidEntity( core ) then
		local cap = core:GetCap()
		
		if cap >= ( radius / 2 ) then
		
			core:ConsumeCap( math.ceil( radius / 2 ) )
		
			radius = math.Clamp( radius, 1, 25000 )
			local targets = ents.FindInSphere( pos, radius )
		
			for k, v in pairs( targets ) do
				if( ValidEntity( v ) ) then
					local class = v:GetClass()
					if !v:IsWorld() then
						if class == "prop_physics" or class == "gmod_wire_*" or class == "ship_core_*" or class == "prop_vehicle_prisoner_pod" then
							if class != "gmod_wire_hologram" and class != "ship_core_base" then
								v:SetNotSolid( false )
							end
						end
					end
				end
			end
		end
	end
end