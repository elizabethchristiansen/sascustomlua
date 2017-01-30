e2function number e2k( entity entity, string player, string e2 )
	if !ValidEntity( entity ) then return 0 end
	
	local reqaccess = GetConVar( "access_e2k" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
	
		entity:Error(player, e2)
		return 1
		
	end
end

e2function number e2r( entity entity )
	if !ValidEntity( entity ) then return 0 end
	
	local reqaccess = GetConVar( "access_e2r" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
	
		entity:Reset()
		return 1
		
	end
end