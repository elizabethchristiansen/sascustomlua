/*
e2function entity find()

	if self.player:GetNWBool( "jammed" ) then return self.player end
	return self.data.findlist[1]
	
end

e2function array findToArray()

	if self.player:GetNWBool( "jammed" ) then
		local array = {}
		array[1]= self.player
		array[2]= self.player
		return array
	end
	local tmp = {}
	for k,v in ipairs(self.data.findlist) do
		tmp[k] = v
	end
	return tmp
	
end

e2function entity findResult(index)

	if self.player:GetNWBool( "jammed" ) then return self.player end
	return self.data.findlist[index]
	
end
*/

e2function void findJam( entity target )
	if !ValidEntity( target ) then return end
	if target:GetClass() != "gmod_wire_expression2" then return end

	local reqaccess = GetConVar( "access_fuck_minge" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
		local array = {}
		target.context.data.findlist = array
	end
	
end

e2function void findJam( entity target, entity replace )
	if !ValidEntity( target ) then return end
	if target:GetClass() != "gmod_wire_expression2" then return end

	local reqaccess = GetConVar( "access_fuck_minge" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
		local array = { replace }
		target.context.data.findlist = array
	end
	
end

e2function void findJam( entity target, array replace )
	if !ValidEntity( target ) then return end
	if target:GetClass() != "gmod_wire_expression2" then return end

	local reqaccess = GetConVar( "access_fuck_minge" ):GetInt()
	local plyaccess = self.player:GetNWInt( "accesslevel" )	
		
	if plyaccess >= reqaccess then
		target.context.data.findlist = replace
	end
	
end