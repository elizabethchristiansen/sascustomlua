AddCSLuaFile('custom.lua') 

registerFunction( "shootTo", "e:vnnn","", function(self, args)
    local op1, op2, op3, op4, op5 = args[2], args[3], args[4], args[5], args[6]
    local rv1, rv2, rv3, rv4, rv5 = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3), op4[1](self, op4), op5[1](self, op5)
	
    local access = GetConVar( "access_shootbeamtoadmin" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	if plyaccess < access then return end

    local bullet = {}
    bullet.Num      = 1
    bullet.Src      = rv1:GetPos()
    bullet.Dir      = Vector(rv2[1], rv2[2], rv2[3])
    bullet.Spread       = Vector( rv3, rv3, 0 )
    bullet.Tracer       = 1
    bullet.TracerName   = "Tracer"
    bullet.Force        = rv4
    bullet.Damage       = rv5
    bullet.Attacker     = self.player
    rv1:FireBullets( bullet )
	
end )

e2function void entity:shootBeamTo( vector dir, number dmg_em, number dmg_exp, number dmg_kin, number dmg_therm )
	if( !validEntity( this ) ) then return end

	local access = GetConVar( "access_shootbeamtoadmin" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	local core = nil
	local e2 = self.entity
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	local traceParam = {}
		traceParam.start = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize()
		traceParam.endpos = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize() * 1000000
		traceParam.filter = this

	local trace = nil
	trace = util.TraceLine( traceParam )
	
	if !trace.Entity:IsValid() then return end

	if plyaccess >= access then

		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		
		if trace.Entity:GetClass() == "sga_shield" then
			trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
		else 			
			SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
		end
	
	elseif ValidEntity( core ) then
	
		dmg_em = math.Clamp( dmg_em, 1, 2500 )
		dmg_exp = math.Clamp( dmg_exp, 1, 2500 )
		dmg_kin = math.Clamp( dmg_kin, 1, 2500 )
		dmg_therm = math.Clamp( dmg_therm, 1, 2500 )
	
		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		local capuse = totaldamage / 2
	
		local cap = core:GetCap()
		
		if ( cap != nil ) and ( cap >= capuse ) then
		
			core:ConsumeCap( math.ceil( capuse ) )
	
			if trace.Entity:GetClass() == "sga_shield" then
				trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
			else 			
				SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
			end
		end
		
	end
	
end

e2function void entity:shootBeamTo( vector dir, number dmg_em, number dmg_exp, number dmg_kin, number dmg_therm, number range )
	if( !validEntity( this ) ) then return end

	local access = GetConVar( "access_shootbeamtoadmin" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	local core = nil
	local e2 = self.entity
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	range = math.Clamp( range, 1, 1000000 )
	
	local traceParam = {}
		traceParam.start = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize()
		traceParam.endpos = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize() * range
		traceParam.filter = this

	local trace = nil
	trace = util.TraceLine( traceParam )
	
	if !trace.Entity:IsValid() then return end

	if plyaccess >= access then

		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		
		if trace.Entity:GetClass() == "sga_shield" then
			trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
		else 			
			SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
		end
	
	elseif ValidEntity( core ) then
	
		dmg_em = math.Clamp( dmg_em, 1, 2500 )
		dmg_exp = math.Clamp( dmg_exp, 1, 2500 )
		dmg_kin = math.Clamp( dmg_kin, 1, 2500 )
		dmg_therm = math.Clamp( dmg_therm, 1, 2500 )
	
		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		local capuse = totaldamage / 2
	
		local cap = core:GetCap()
		
		if ( cap != nil ) and ( cap >= capuse ) then
		
			core:ConsumeCap( math.ceil( capuse ) )
	
			if trace.Entity:GetClass() == "sga_shield" then
				trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
			else 			
				SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
			end
		end
		
	end
	
end

e2function void entity:shootBeamTo( vector dir, number dmg_em, number dmg_exp, number dmg_kin, number dmg_therm, string voidadmin )
	if( !validEntity( this ) ) then return end

	local access = GetConVar( "access_shootbeamtoadmin" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	local core = nil
	local e2 = self.entity
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	local traceParam = {}
		traceParam.start = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize()
		traceParam.endpos = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize() * 1000000
		traceParam.filter = this

	local trace = nil
	trace = util.TraceLine( traceParam )
	
	if !trace.Entity:IsValid() then return end

	if plyaccess >= access and voidadmin == "false" then

		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		
		if trace.Entity:GetClass() == "sga_shield" then
			trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
		else 			
			SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
		end
	
	elseif ValidEntity( core ) and voidadmin == "true" then
	
		dmg_em = math.Clamp( dmg_em, 1, 2500 )
		dmg_exp = math.Clamp( dmg_exp, 1, 2500 )
		dmg_kin = math.Clamp( dmg_kin, 1, 2500 )
		dmg_therm = math.Clamp( dmg_therm, 1, 2500 )
	
		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		local capuse = totaldamage / 2
	
		local cap = core:GetCap()
		
		if ( cap != nil ) and ( cap >= capuse ) then
		
			core:ConsumeCap( math.ceil( capuse ) )
	
			if trace.Entity:GetClass() == "sga_shield" then
				trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
			else 			
				SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
			end
		end
		
	end
	
end

e2function void entity:shootBeamTo( vector dir, number dmg_em, number dmg_exp, number dmg_kin, number dmg_therm, number range, string voidadmin )
	if( !validEntity( this ) ) then return end

	local access = GetConVar( "access_shootbeamtoadmin" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )
	
	local core = nil
	local e2 = self.entity
	
	if ValidEntity( this.SC_CoreEnt ) then
		core = this.SC_CoreEnt
	elseif ValidEntity( e2.SC_CoreEnt ) then
		core = e2.SC_CoreEnt
	end
	
	range = math.Clamp( range, 1, 1000000 )
	
	local traceParam = {}
		traceParam.start = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize()
		traceParam.endpos = this:GetPos() + Vector(dir[1],dir[2],dir[3]):Normalize() * range
		traceParam.filter = this

	local trace = nil
	trace = util.TraceLine( traceParam )
	
	if !trace.Entity:IsValid() then return end

	if plyaccess >= access and voidadmin == "false" then

		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		
		if trace.Entity:GetClass() == "sga_shield" then
			trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
		else 			
			SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
		end
	
	elseif ValidEntity( core ) and voidadmin == "true" then
	
		dmg_em = math.Clamp( dmg_em, 1, 2500 )
		dmg_exp = math.Clamp( dmg_exp, 1, 2500 )
		dmg_kin = math.Clamp( dmg_kin, 1, 2500 )
		dmg_therm = math.Clamp( dmg_therm, 1, 2500 )
	
		local totaldamage = dmg_em + dmg_exp + dmg_kin + dmg_therm
		local capuse = totaldamage / 2
	
		local cap = core:GetCap()
		
		if ( cap != nil ) and ( cap >= capuse ) then
		
			core:ConsumeCap( math.ceil( capuse ) )
	
			if trace.Entity:GetClass() == "sga_shield" then
				trace.Entity:Hit( self, trace.HitPos, totaldamage, -1*trace.Normal )
			else 			
				SC_ApplyDamage( trace.Entity, { EM = ( dmg_em ), EXP = ( dmg_exp ), KIN = ( dmg_kin ), THERM = ( dmg_therm ) }, self.Owner, self.Entity )
			end
		end
		
	end
	
end