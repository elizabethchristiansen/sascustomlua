e2function void entity:tele( vector pos )
	if !ValidEntity( this ) then return end

	local reqaccess = GetConVar( "access_tele" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
	
	if plyaccess >= reqaccess then	
		local vec = Vector( pos[1], pos[2], pos[3] )
		this:SetPos( vec )
	end
end
