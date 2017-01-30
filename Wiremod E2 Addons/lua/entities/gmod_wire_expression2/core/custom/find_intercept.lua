e2function array findIntercept( entity target )
	local array = {}

	if !ValidEntity( target ) then return array end
	if target:GetClass() != "gmod_wire_expression2" then return array end
		
	for k, v in pairs( target.context.data.findlist ) do
		array[ k ] = v
	end
	
	return array
end