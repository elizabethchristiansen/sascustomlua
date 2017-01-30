local function CheckIndex(self, index)
	index = index - index % 1
	local Holo
	if index<0 then
		Holo = E2HoloRepo[self.player][-index]
	else
		Holo = self.data.holos[index]
	end
	if not Holo or not validEntity(Holo.ent) then return nil end
	return Holo
end


registerFunction( "holoModelAny", "ns", "", function( self, args )
	local op1,op2 = args[2],args[3]
	local rv1,rv2 = op1[1](self, op1),op2[1](self, op2)
	
	local Holo = CheckIndex(self, rv1)
	if not Holo then return end
	
	Holo.ent:SetModel( Model( rv2 ) )
end )