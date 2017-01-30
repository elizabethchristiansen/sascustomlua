
/******************************************
	Make Gcombat Weapons Work in my System
*******************************************/

COMBATDAMAGEENGINE = 1

gcombat = {}

function gcombat.hcgexplode( position, radius, damage, pierce )
    if not GetCvarBool("scvar_Dmg") then return false end

	local damaged = ents.FindInSphere( position, radius)
	--local tooclose = ents.FindInSphere( position, 5)
	
	local fallofftable = {}
	local hitentstable = {}
	
	for _,i in pairs(damaged) do
	
		local distance = (i:NearestPoint(position) - position):Length() -- New way
	    local falloff = (1 - (distance/radius))
	    --Msg("=====\nFalloff: " ..tostring(falloff).."\nDistance: "..tostring(distance).."\n=====\n")
		if falloff < 0 then
			Msg("\nWTF FALLOFF < 0!!!! "..tostring(distance).."\n\n")
			falloff = 0
		end  
	    local dtd = (damage * falloff)/4
	    local damage_to_deal = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
	    local tr = nil  
	    
		local trace = { 
			start = position,
			endpos = i:NearestPoint(position),
			--filter = tooclose,
		}
		tr = util.TraceLine( trace ) 
		
		if tr.HitWorld == false then
			if tr.Entity:IsValid() and table.HasValue( SC_Shields, tr.Entity:GetClass() ) then
			else
				if i.SC_CoreEnt != nil then
					hitentstable[falloff] = i
					table.insert(fallofftable, falloff)
				else 				    
	    			SC_ApplyDamage(i, damage_to_deal, nil, nil, position)
				end	
	    	end	
		end	
	end
	local alreadyhit = {}
	for _,f in pairs(fallofftable) do 
		local test = hitentstable[f].SC_CoreEnt
		if table.HasValue(alreadyhit, test) then
			
		else
			local falloff = f
			local dtd = (damage * falloff)/4
	    	local damage_to_deal = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
			table.insert(alreadyhit, test)
			SC_ApplyDamage(hitentstable[f], damage_to_deal, attacker, inflictor ) 		
			--Msg(tostring(test).."\n")
		end		
	end 	
end

cbt_hcgexplode = gcombat.hcgexplode

function gcombat.nrgexplode( position, radius, damage, pierce)
    if not GetCvarBool("scvar_Dmg") then return false end

	local damaged = ents.FindInSphere( position, radius)
	--local tooclose = ents.FindInSphere( position, 5)
	
	local fallofftable = {}
	local hitentstable = {}
	
	for _,i in pairs(damaged) do
	
		local distance = (i:NearestPoint(position) - position):Length() -- New way
	    local falloff = (1 - (distance/radius))
	    --Msg("=====\nFalloff: " ..tostring(falloff).."\nDistance: "..tostring(distance).."\n=====\n")
		if falloff < 0 then
			Msg("\nWTF FALLOFF < 0!!!! "..tostring(distance).."\n\n")
			falloff = 0
		end  
	    local dtd = (damage * falloff)/4
	    local damage_to_deal = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
	    local tr = nil  
	    
		local trace = { 
			start = position,
			endpos = i:NearestPoint(position),
			--filter = tooclose,
		}
		tr = util.TraceLine( trace ) 
		
		if tr.HitWorld == false then
			if tr.Entity:IsValid() and table.HasValue( SC_Shields, tr.Entity:GetClass() ) then
			else
	    		if i.SC_CoreEnt != nil then
					hitentstable[falloff] = i
					table.insert(fallofftable, falloff)
				else 				    
	    			SC_ApplyDamage(i, damage_to_deal, nil, nil, position)
				end		
	    	end	
		end	
	end
	local alreadyhit = {}
	for _,f in pairs(fallofftable) do 
		local test = hitentstable[f].SC_CoreEnt
		if table.HasValue(alreadyhit, test) then
			
		else
			local falloff = f
			local dtd = (damage * falloff)/4
	   		local damage_to_deal = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
			table.insert(alreadyhit, test)
			SC_ApplyDamage(hitentstable[f], damage_to_deal, attacker, inflictor ) 		
			--Msg(tostring(test).."\n")
		end		
	end 	
end

cbt_nrgexplode = gcombat.nrgexplode

function gcombat.nrghit( entity, damage, pierce, src, dest)
    if not GetCvarBool("scvar_Dmg") then return false end

	local dtd = (damage)/4
	local damage2 = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
	
	if entity:IsValid() and entity:GetClass() == "shield" then  --Do some shield damage

	    entity.Parent.Strength = math.Clamp(entity.Parent.Strength-((((damage/2)/SC_SG_Shield_MaxDamage())*100)/(entity.Parent.StrengthMultiplier[1]*entity.Parent.StrengthConfigMultiplier)),0,100)
		entity:Hit(entity,src,1.0) --So it still plays the shields hit effect

	else
		SC_ApplyDamage(entity, damage2)
	end
end

cbt_dealnrghit = gcombat.nrghit

function gcombat.hcghit( entity, damage, pierce, src, dest) 
    if not GetCvarBool("scvar_Dmg") then return false end

	local dtd = (damage)/4
	local damage2 = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
	
	if entity:IsValid() and entity:GetClass() == "shield" then  --Do some shield damage

	    entity.Parent.Strength = math.Clamp(entity.Parent.Strength-((((damage/2)/SC_SG_Shield_MaxDamage())*100)/(entity.Parent.StrengthMultiplier[1]*entity.Parent.StrengthConfigMultiplier)),0,100)
		entity:Hit(entity,src,1.0) --So it still plays the shields hit effect

	else
		SC_ApplyDamage(entity, damage2)
	end
end

cbt_dealhcghit = gcombat.hcghit

function gcombat.devhit( entity, damage, pierce)
    if not GetCvarBool("scvar_Dmg") then return false end

	local dtd = (damage)/4
	local damage2 = {EM=dtd, EXP=dtd, KIN=dtd, THERM=dtd}
	
	if entity:IsValid() and entity:GetClass() == "shield" then  --Do some shield damage

	    entity.Parent.Strength = math.Clamp(entity.Parent.Strength-((((damage/2)/SC_SG_Shield_MaxDamage())*100)/(entity.Parent.StrengthMultiplier[1]*entity.Parent.StrengthConfigMultiplier)),0,100)
		entity:Hit(entity,src,1.0) --So it still plays the shields hit effect

	else
		SC_ApplyDamage(entity, damage2)
	end
end

cbt_dealdevhit = gcombat.devhit


function gcombat.applyheat(ent, temp)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_applyheat = gcombat.applyheat


function gcombat.emitheat( position, radius, temp, own)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_emitheat = gcombat.emitheat




	    