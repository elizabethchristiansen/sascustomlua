e2function number entity:hasCore()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		return 1
	else 
		return 0
	end
	
end

e2function number entity:getCoreShield()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local s = coreinfo.shield
		
		return s
	else
		return 0
	end
	
end

e2function number entity:getCoreShieldMax()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local sm = coreinfo.shieldmax
		
		return sm
	else
		return 0
	end

end

e2function number entity:getCoreArmor()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local a = coreinfo.armor
		
		return a
	else
		return 0
	end

end

e2function number entity:getCoreArmorMax()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local am = coreinfo.armormax		
		return am
	else
		return 0
	end

end

e2function number entity:getCoreHull()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local h = coreinfo.hull
		
		return h
	else
		return 0
	end

end

e2function number entity:getCoreHullMax()
	if( !validEntity( this ) ) then return end
	local core = this.SC_CoreEnt
	
	if core != nil then
		local coreinfo = core:GetCoreInfo()
		local hm = coreinfo.hullmax
		
		return hm
	else
		return 0
	end

end