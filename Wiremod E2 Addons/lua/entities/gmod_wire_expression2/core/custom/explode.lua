e2function void entity:scexplode( number radius, number dmg_em, number dmg_exp, number dmg_kin, number dmg_therm ) 
    local coreids_hit = {}
    local hit_core = nil
    local ent_idx = nil
	local ent_pos = nil
	
	local reqaccess = GetConVar( "access_scexplode" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
	
	local core = nil
	local e2 = self.entity
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	if plyaccess >= reqaccess then
		if this == nil then return end
		
		for _, entity in pairs(ents.FindInSphere(this:GetPos(), radius)) do      
			if(entity != nil and entity:IsValid()) then
				hit_core = entity.SC_CoreEnt
				if(hit_core != nil) then
					ent_idx = hit_core:EntIndex()
					if(coreids_hit[ent_idx] == nil) then
						coreids_hit[ent_idx] = hit_core
						SC_ApplyDamage(entity, {EM=(dmg_em),EXP=(dmg_exp),KIN=(dmg_kin),THERM=(dmg_therm)}, self.Owner, self.Entity)
					end
				else
					SC_ApplyDamage(entity, {EM=(dmg_em),EXP=(dmg_exp),KIN=(dmg_kin),THERM=(dmg_therm)}, self.Owner, self.Entity)
				end
			end
		end
	elseif ValidEntity( core ) then
	
		dmg_em = math.Clamp( dmg_em, 1, 2500 )
		dmg_exp = math.Clamp( dmg_exp, 1, 2500 )
		dmg_kin = math.Clamp( dmg_kin, 1, 2500 )
		dmg_therm = math.Clamp( dmg_therm, 1, 2500 )
		
		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
	
		local cap = core:GetCap()
		
		if ( cap != nil ) and ( cap >= totaldamage ) then
		
			core:ConsumeCap( math.ceil( totaldamage ) )
			
			if this == nil then return end
		
			for _, entity in pairs(ents.FindInSphere(this:GetPos(), radius)) do      
				if(entity != nil and entity:IsValid()) then
					hit_core = entity.SC_CoreEnt
					if(hit_core != nil) then
						ent_idx = hit_core:EntIndex()
						if(coreids_hit[ent_idx] == nil) then
							coreids_hit[ent_idx] = hit_core
							SC_ApplyDamage(entity, {EM=(dmg_em),EXP=(dmg_exp),KIN=(dmg_kin),THERM=(dmg_therm)}, self.Owner, self.Entity)
						end
					else
						SC_ApplyDamage(entity, {EM=(dmg_em),EXP=(dmg_exp),KIN=(dmg_kin),THERM=(dmg_therm)}, self.Owner, self.Entity)
					end
				end
			end
		end
	end
end